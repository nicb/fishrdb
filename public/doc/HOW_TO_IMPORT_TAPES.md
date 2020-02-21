# How to import new tapes

1. sync the NAS with the hi-rez copies of the tapse
1. make sure the following structure of symbolic links is in place:
```
    public/private
    ├── hifi -> ../../../../../tapes/
    ├── lofi -> tapes_lofi
    ├── tapes -> ../../../../../tapes/
    ├── tapes_lofi -> ../../../../../tapes_lofi/1/
    └── tapes_PRODUCTION -> ../../../../../tapes/
```
   (the import will not work without this structure)
1. run the following command-line:
```bash
$ LAME_OPTIONS="--quiet" nohup rake tapes:lofi:create
```
1. copy an updated version of the file `ScelsiDatabase.csv` into `public/private/session-notes`. Please note: the `ScelsiDatabase.csv` file must contain only the info of all files up to the latest imported hi-rez.
1. after having created the proper lofi structure, run:
```bash
rake db:tapes:create
```
