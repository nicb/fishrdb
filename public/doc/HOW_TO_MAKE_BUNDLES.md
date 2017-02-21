# How to make tape bundles

* create a `yml` file `<whatever>-<date>.yml` and place it in `~/tmp`
* run the following command-line programs
```bash
$ rake fishrdb:bundle:create
Configuration file []: ../../../tmp/<whatever>-<date>.yml
```
* if the `.yml` file has the correct syntax it should produce the required bundle in the `fishrdb/tmp/` directory (or wherever).

## configuration file format
