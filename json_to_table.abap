method JSON_TO_TABLE.
  DATA: lo_typed TYPE REF TO cl_abap_typedescr,
        lo_struc TYPE REF TO data,
        lv_lengt TYPE string,
        lv_value TYPE string,
        lv_numbr TYPE string,
        lv_error TYPE abap_bool,
        lv_endtg TYPE abap_bool.

  FIELD-SYMBOLS: <struc> TYPE data.

  ADD 1 TO offset.

  CREATE DATA lo_struc LIKE LINE OF otable.
  ASSIGN lo_struc->* TO <struc>.
  lo_typed = cl_abap_typedescr=>describe_by_data( <struc> ).

  WHILE lv_endtg EQ abap_false.
    FIND REGEX '\{|\[|"([^"]*)"|([\d\.\w]+)' IN SECTION OFFSET offset OF json
      MATCH OFFSET offset MATCH LENGTH lv_lengt
      SUBMATCHES lv_value lv_numbr.
    IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.

    CASE json+offset(1).
      WHEN '{'.
        IF lo_typed->type_kind EQ lo_typed->typekind_struct1 OR lo_typed->type_kind EQ lo_typed->typekind_struct2.
          me->json_to_structure( EXPORTING json = json CHANGING object = <struc> offset = offset ).
          INSERT <struc> INTO TABLE otable.
          CLEAR <struc>.
        ELSE.
          lv_error = abap_true.
        ENDIF.
      WHEN '['.
        IF lo_typed->type_kind EQ lo_typed->typekind_table.
          me->json_to_table( EXPORTING json = json CHANGING otable = <struc> offset = offset ).
          INSERT <struc> INTO TABLE otable.
          FREE <struc>.
        ELSE.
          lv_error = abap_true.
        ENDIF.
      WHEN '"'.
        IF lo_typed->type_kind NE lo_typed->typekind_struct1 AND
           lo_typed->type_kind NE lo_typed->typekind_struct2 AND
           lo_typed->type_kind NE lo_typed->typekind_table.
          <struc> = lv_value.
          REPLACE ALL OCCURRENCES OF `\'` IN <struc> WITH '"'.
          INSERT <struc> INTO TABLE otable.
          CLEAR <struc>.
        ELSE.
          lv_error = abap_true.
        ENDIF.
      WHEN OTHERS.
        IF lo_typed->type_kind NE lo_typed->typekind_struct1 AND
           lo_typed->type_kind NE lo_typed->typekind_struct2 AND
           lo_typed->type_kind NE lo_typed->typekind_table.
          TRANSLATE lv_numbr TO UPPER CASE.
          CASE lv_numbr.
            WHEN 'NULL'.
              CLEAR <struc>.
            WHEN 'TRUE'.
              <struc> = abap_true.
            WHEN 'FALSE'.
              <struc> = abap_false.
            WHEN OTHERS.
              <struc> = lv_numbr.
          ENDCASE.
          INSERT <struc> INTO TABLE otable.
          CLEAR <struc>.
        ELSE.
          lv_error = abap_true.
        ENDIF.
    ENDCASE.

    ADD lv_lengt TO offset.

    IF lv_error EQ abap_true.
      lv_error = abap_false.
      FIND REGEX '\]' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_value.
      IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.
    ENDIF.

    FIND REGEX ',|\]' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_value.
    IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.

    IF json+offset(1) EQ ']'.
      lv_endtg = abap_true.
    ELSE.
      ADD 1 TO offset.
    ENDIF.

  ENDWHILE.

endmethod.
