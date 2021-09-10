# Glamorous Toolkit for openEdx
A repository dedicated to analyses of [openEdx](https://github.com/edx) that reproduce the contents presented in [our blog post about steering agile architecture by example](https://lepiter.io/feenk/steering-agile-architecture-by-example--th-e2p6aps2brbby94deek31xqxh/).

## Install

Install [Glamorous Toolkit](https://gtoolkit.com).

Then open a Playground and load the code in Glamorous Toolkit by executing:

```
Metacello new
	repository: 'github://feenkcom/gt4edx:main/src';
	baseline: 'GToolkit4Edx';
	load
```

And then load the documentation in Glamorous Toolkit:

```
BaselineOfGToolkit4Edx loadLepiter
```
