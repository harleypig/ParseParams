# NAME

ParseParams - Parse command line or function parameters.

# SYNOPSIS

    source ParseParams

    PARM_DEF='
    a|app,string,AppName,,required
    b|bank,number,BankNumber
    c,boolean
    '
    parse_params "$PARM_DEF" "$@" || show_usage

# OPTIONS

There are no options for sourcing the library itself. For the `parse_params`
function, the following describes the required input.

The first parameter is the parameter definition string, described below.

The remaining parameters are the input parameters to be validated.

NOTE: Not explicitly including "$@" is allowed but this scenario has not been
tested.

# DESCRIPTION

The ParseParams library takes a definition string and validates input
parameters against that definition, setting variables to those values if they
pass the various checks. Otherwise an error message is returned and the
calling script is exited.

# TYPES

Valid types are detailed below.

## string

Simply checks for a non-empty value.

## filename

Checks if the value is a valid filename and if it exists is it readable, or if
it does not exist can we create it. If it is readable or creatable, returns 0.
Otherwise returns 1.

This type expects the path to the filename to exist. If it does not, it will
fail (return 1).

If you want to allow the caller to provide just the base filename and you will
build the path, don't use this type. Just use the `string` type and call
`qualify_filename` (from the utility library) after you have built the
string.

## char

Checks for a single character value.

## integer

Checks that a value is a positive integer (a number without a decimal).

## boolean

This type does not check for a value. The boolean type forces the variable to
be either a 0 (true) or 1 (false).

See the `parse_params` section for more information.

## date

Checks that a value appears to be a valid date and returns either a 0 (true)
if the `date` program can parse the value correctly or 1 (false) if not.

## varname

Checks that a value appears to be a valid shell variable name and returns
either a 0 (true) if it does, or 1 (false) if not.

# FUNCTIONS

## parse\_params

Expects the first parameter to be a format string that defines options and
types so that parameters can be validated, to a minimal degree. The developer
can validate parameters for their specific needs.

The variable name defined by the definition line will be set to the matching
input value.

The remaining parameters are the input values that need to be validated.

A definition line is made up of five (5) fields, separated by commas and/or
spaces:

**OPTION, TYPE, VARNAME, DEFAULT, REQUIRED**

**OPTION** and **TYPE** are required. A minimal definition line would look like:

    a,appname

The variable named `a` would be set to `appname`.

The remaining three fields are optional. If you want to provide a default
value, but not make the parameter required or have a different varname, your
definition line would look like:

    a|app,string,,appname

If no parameter was used on the command line, `app` would be set to
`appname`.

Another possible definition is to set the first field to '#'. This will cause
`parse_params` to look for positional parameters. Since these are checked for
last, any definitions with the same variable name will be overwritten with the
positional value.

### OPTION

**OPTION** is a required field and can be any string.

**OPTION** can define a short option--a dash (-) followed by a single character,
a long option--a double dash (--) followed by a string, or a short option and
a long option separated by a pipe (|).

If **VARNAME** is not provided then **VARNAME** will be set to the long option
if it exists, or the short option if it does not.

### TYPE

**TYPE** is a required field and can be any of the types defined in the
`TYPES` section. See that section for what each type does.

If **TYPE** is `boolean`, the **REQUIRED** field is forced to be `optional` and
**VARNAME** is forced to be either `0` (true) or `1` (false).

If **TYPE** is `boolean` it does not make sense to have a default setting. If
the switch is not used on the command line **VARNAME** will be 1. If
**VARNAME** is used on the command line it will be 0.

If a default is set in the parameter definition, it will be ignored.

### VARNAME

**VARNAME** is optional and will default to the long option, or if none
provided, the short option.

**VARNAME** will be set to the matching input parameter.

### DEFAULT

**DEFAULT** is optional.

IF **DEFAULT** is set and the parameter is not used on the command line,
**VARNAME** will be set to the matching input parameter. Otherwise **VARNAME**
will be set to `NULL`, except for type `boolean` as described above.

### REQUIRED

**REQUIRED** is optional and will default to `optional`.

**REQUIRED** can be either `required` or `optional` and is case insensitive.
I.e., `required`, `REQUIRED` and `Required` are identical.

If **REQUIRED** is `required` the parameter must be included on the command
line.

# INTERNAL FUNCTIONS

These functions should not be used unless you know exactly what you are doing.

## \_check\_type

Checks to see if the value of a variable is a valid type.

If the value of the variable evaluates to `null`, then `_check_type` will
return 0.

## \_build\_parms\_info

Normalizes the various ways a definition string can be defined into
a stricter, normalized string for use in `_build_eval_string` below.

## \_build\_eval\_string

Builds a string that will be eval'd and defines the `_parse_params` function
based on the definition lines passed to `parse_params`.

## \_parse\_params

This is a dynamic function, built on the fly as a string and eval'd and then
called in `parse_params`.
