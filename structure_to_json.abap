method STRUCTURE_TO_JSON.
  DATA: lo_type TYPE REF TO cl_abap_typedescr,
        lo_stru TYPE REF TO cl_abap_structdescr,
        lt_comp TYPE STANDARD TABLE OF abap_componentdescr,
        wa_comp TYPE abap_componentdescr,
        len     TYPE i.

  FIELD-SYMBOLS: <struc> TYPE ANY,
                 <comp>  TYPE ANY.

  lo_type = otype.
  lo_stru ?= lo_type.
  json = |{ json }{ c_s }|.
  ASSIGN object TO <struc>.
  lt_comp = lo_stru->get_components( ).

  LOOP AT lt_comp INTO wa_comp.

    ASSIGN COMPONENT sy-tabix OF STRUCTURE <struc> TO <comp>.
    CLEAR lo_type.
    lo_type = cl_abap_typedescr=>describe_by_data( <comp> ).

    IF lo_type->type_kind EQ lo_type->typekind_table.
      json = |{ json }"{ wa_comp-name }": |.
      me->table_to_json( EXPORTING otype = lo_type otable = <comp> CHANGING json = json ).
      json = |{ json },|.
    ELSEIF lo_type->type_kind EQ lo_type->typekind_char AND lo_type->length EQ 2.
      IF <comp> EQ abap_true.
        json = |{ json }"{ wa_comp-name }": true,|.
      ELSE.
        json = |{ json }"{ wa_comp-name }": false,|.
      ENDIF.
    ELSE.
      IF <comp> IS INITIAL.
        json = |{ json }"{ wa_comp-name }": null,|.
      ELSE.
        json = |{ json }"{ wa_comp-name }": "{ <comp> }",|.
      ENDIF.
    ENDIF.

  ENDLOOP.
  len = strlen( json ) - 1. json = json(len).
  json = |{ json }{ c_e }|.

endmethod.
