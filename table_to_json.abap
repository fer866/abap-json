*========================================
* Private instance
* importing otype  TYPE REF TO CL_ABAP_TYPEDESCR
* importing otable TYPE any table
* changing  json   TYPE string
*========================================
method TABLE_TO_JSON.
  DATA: lo_type TYPE REF TO cl_abap_typedescr,
        lo_stru TYPE REF TO cl_abap_structdescr,
        lo_tabl TYPE REF TO cl_abap_tabledescr,
        len     TYPE i.

  FIELD-SYMBOLS: <struc> TYPE ANY.

  lo_tabl ?= otype.
  lo_stru ?= lo_tabl->get_table_line_type( ).
  lo_type ?= lo_stru.

  json = |{ json }{ c_sc }|.

  LOOP AT otable ASSIGNING <struc>.
    lo_type = cl_abap_typedescr=>describe_by_data( <struc> ).
    me->structure_to_json( EXPORTING otype  = lo_type object = <struc> CHANGING json = json ).
    json = |{ json },|.
  ENDLOOP.
  IF otable IS NOT INITIAL.
    len = strlen( json ) - 1. json = json(len).
  ENDIF.
  json = |{ json }{ c_ec }|.

endmethod.
