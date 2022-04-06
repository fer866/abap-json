method CONVERT_DATA_TOJSON.
  DATA: lo_type TYPE REF TO cl_abap_typedescr.

  lo_type = cl_abap_typedescr=>describe_by_data( object ).

  CASE lo_type->type_kind.
    WHEN lo_type->typekind_struct1 OR lo_type->typekind_struct2.    "-------------------------- STRUCTURE OR DEEP STRUCTURE
      me->structure_to_json( EXPORTING otype = lo_type object = object CHANGING json = json ).

    WHEN lo_type->typekind_table.      "------------------------------------------------------- TABLE
      me->table_to_json( EXPORTING otype = lo_type otable = object CHANGING json = json ).

    WHEN OTHERS.
      sy-subrc = 4.
  ENDCASE.

endmethod.
