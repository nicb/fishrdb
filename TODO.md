# Tape Import TODO

* cambiare strategia di importazione:
  * oggetto `Tape::Importer` che ha un metodo `import(from, to)` che importa
    da-a
  * oggetto `ConstrainedMapper < Mapper` che viene chiamato da
    `Tape::Importer`
  * output? direttamente in db? oppure produce un output mysql da essere
    importato a mano?
* aggiungere `rake tasks` che permettono un front-end semplice
* *documentare il tutto* in modo da non doversi scervellare ogni volta :-\
