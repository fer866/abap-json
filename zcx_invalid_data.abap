*========================================
* Texts
* ZCX_INVALID_DATA_JSON_IDX = Formato JSON incorrecto en el índice &indice&
*========================================
class ZCX_INVALID_DATA definition
  public
  inheriting from CX_STATIC_CHECK
  final
  create public .

public section.

  constants ZCX_INVALID_DATA type SOTR_CONC value 'A0369F0B67761ED8BF96685D599640C2'. "#EC NOTEXT
  constants ZCX_INVALID_DATA_PERIOD type SOTR_CONC value 'A0369F0B67761ED8BF966958214880C2'. "#EC NOTEXT
  constants ZCX_INVALID_DATA_JSON_IDX type SOTR_CONC value 'A0369F0B67761ED8BF966B984FF280C2'. "#EC NOTEXT
  constants ZCX_INVALID_DATA_PRESUP type SOTR_CONC value 'A0369F0B67761EDA93B63D908F9AC0C6'. "#EC NOTEXT
  data PERIODO type STRING .
  data INDICE type I .
  data DATA_PRESUP type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !PERIODO type STRING optional
      !INDICE type I optional
      !DATA_PRESUP type STRING optional .
