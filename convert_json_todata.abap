method CONVERT_JSON_TODATA.
  DATA: lo_type  TYPE REF TO cl_abap_typedescr,
        lv_offst TYPE i,
        lv_sname TYPE string,
        lv_lengt TYPE i,
        lv_value TYPE string,
        lv_numbr TYPE string.

  lo_type = cl_abap_typedescr=>describe_by_data( object ).

* Replaces special characters in strings
  me->format_sp_char_json( CHANGING json = json ).

  FIND REGEX '\{|\[|"([^"]*)"|(\d+)' IN SECTION OFFSET lv_offst OF json MATCH OFFSET lv_offst.

  CASE lo_type->type_kind.
    WHEN lo_type->typekind_struct1 OR lo_type->typekind_struct2.    "-------------------------- STRUCTURE OR DEEP STRUCTURE
      IF json+lv_offst(1) NE '{'.
        "RAISE EXCEPTION TYPE zcx_invalid_data.
      ENDIF.
      TRY.
        me->json_to_structure( EXPORTING json = json CHANGING object = object offset = lv_offst ).
      CATCH zcx_invalid_data.
      ENDTRY.
    WHEN lo_type->typekind_table.      "------------------------------------------------------- TABLE
      IF json+lv_offst(1) NE '['.
        "RAISE EXCEPTION TYPE zcx_invalid_data.
      ENDIF.
      TRY.
        me->json_to_table( EXPORTING json = json CHANGING otable = object offset = lv_offst ).
      CATCH zcx_invalid_data.
      ENDTRY.
    WHEN OTHERS.
      TRY.
        me->json_to_component( EXPORTING json = json CHANGING object = object offset = lv_offst ).
      CATCH zcx_invalid_data.
      ENDTRY.
  ENDCASE.
endmethod.
