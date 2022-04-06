*========================================
* Private instance
* importing json   TYPE string
* changing  object TYPE any
* changing  offset TYPE i DEFAULT 0
* exception zcx_invalid_data
*========================================
method JSON_TO_STRUCTURE.
  DATA: lv_lengt TYPE i,
        lv_sname TYPE string,
        lv_value TYPE string,
        lv_endtg TYPE abap_bool,
        lv_numbr TYPE string,
        lo_type  TYPE REF TO cl_abap_typedescr.

  FIELD-SYMBOLS: <struc> TYPE ANY,
                 <compt> TYPE ANY.

  ADD 1 TO offset.

  WHILE lv_endtg EQ abap_false.
    FIND REGEX '"([^"]*)"' IN SECTION OFFSET offset OF json
      MATCH OFFSET offset MATCH LENGTH lv_lengt
      SUBMATCHES lv_sname.
    IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.
    TRANSLATE lv_sname TO UPPER CASE.
    ADD lv_lengt TO offset.

    FIND REGEX '\{|\[|"([^"]*)"|([\d\.\w]+)' IN SECTION OFFSET offset OF json
      MATCH OFFSET offset MATCH LENGTH lv_lengt
      SUBMATCHES lv_value lv_numbr.
    IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.

    CASE json+offset(1).
      WHEN '{'.   "Structure
        ASSIGN COMPONENT lv_sname OF STRUCTURE object TO <compt>.
        IF sy-subrc EQ 0.
          me->json_to_structure( EXPORTING json = json CHANGING object = <compt> offset = offset ).
        ELSE.
          FIND REGEX '\}' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_value.
          IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.
        ENDIF.
      WHEN '['.   "Table
        ASSIGN COMPONENT lv_sname OF STRUCTURE object TO <compt>.
        IF sy-subrc EQ 0.
          lo_type = cl_abap_typedescr=>describe_by_data( <compt> ).
          IF lo_type->type_kind EQ lo_type->typekind_table.
            me->json_to_table( EXPORTING json = json CHANGING otable = <compt> offset = offset ).
          ELSE.
            FIND REGEX '\]' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_value.
            IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.
          ENDIF.
        ELSE.
          FIND REGEX '\]' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_value.
          IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.
        ENDIF.
      WHEN '"'.   "Component
        ASSIGN COMPONENT lv_sname OF STRUCTURE object TO <compt>.
        IF sy-subrc EQ 0.
          <compt> = lv_value.
          REPLACE ALL OCCURRENCES OF `\'` IN <compt> WITH '"'.
        ENDIF.
      WHEN OTHERS.    "numbers or null or boolean
        ASSIGN COMPONENT lv_sname OF STRUCTURE object TO <compt>.
        IF sy-subrc EQ 0.
          TRANSLATE lv_numbr TO UPPER CASE.
          CASE lv_numbr.
            WHEN 'NULL'.
              CLEAR <compt>.
            WHEN 'TRUE'.
              <compt> = abap_true.
            WHEN 'FALSE'.
              <compt> = abap_false.
            WHEN OTHERS.
              <compt> = lv_numbr.
          ENDCASE.
        ENDIF.
    ENDCASE.

    ADD lv_lengt TO offset.

    FIND REGEX ',|\}' IN SECTION OFFSET offset OF json MATCH OFFSET offset MATCH LENGTH lv_lengt SUBMATCHES lv_value.
    IF sy-subrc NE 0. RAISE EXCEPTION TYPE zcx_invalid_data EXPORTING textid = zcx_invalid_data=>zcx_invalid_data_json_idx indice = offset. ENDIF.

    IF json+offset(1) EQ '}'.
      lv_endtg = abap_true.
    ELSE.
      ADD 1 TO offset.
    ENDIF.

  ENDWHILE.

endmethod.
