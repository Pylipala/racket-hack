#lang scribble/doc
@(require scribble/manual
          scribble/struct
          scribble/decode
          scribble/eval
          "parse-common.rkt")

@title[#:tag "stxparse-specifying"]{Specifying syntax with syntax classes}

@declare-exporting[syntax/parse]

Syntax classes provide an abstraction mechanism for @tech{syntax
patterns}. Built-in syntax classes are supplied that recognize basic
classes such as @scheme[identifier] and @scheme[keyword].  Programmers
can compose basic syntax classes to build specifications of more
complex syntax, such as lists of distinct identifiers and formal
arguments with keywords. Macros that manipulate the same syntactic
structures can share syntax class definitions.

@defform*/subs[#:literals (pattern)
               [(define-syntax-class name-id stxclass-option ...
                  stxclass-variant ...+)
                (define-syntax-class (name-id . kw-formals) stxclass-option ... 
                  stxclass-variant ...+)]
               ([stxclass-option
                 (code:line #:attributes (attr-arity-decl ...))
                 (code:line #:description description-expr)
                 (code:line #:opaque)
                 (code:line #:commit)
                 (code:line #:no-delimit-cut)
                 (code:line #:literals (literal-entry ...))
                 (code:line #:literal-sets (literal-set ...))
                 (code:line #:conventions (convention-id ...))
                 (code:line #:local-conventions (convention-rule ...))]
                [attr-arity-decl
                 attr-name-id
                 (attr-name-id depth)]
                [stxclass-variant
                 (pattern syntax-pattern pattern-directive ...)])
               #:contracts ([description-expr (or/c string? #f)])]{

Defines @scheme[name-id] as a @deftech{syntax class}, which
encapsulates one or more @tech{single-term patterns}.

A syntax class may have formal parameters, in which case they are
bound as variables in the body. Syntax classes support optional
arguments and keyword arguments using the same syntax as
@scheme[lambda]. The body of the syntax-class definition contains a
non-empty sequence of @scheme[pattern] variants.

The following options are supported:

@specsubform/subs[(code:line #:attributes (attr-arity-decl ...))
                  ([attr-arity-decl attr-id
                                    (attr-id depth)])]{

Declares the attributes of the syntax class. An attribute arity
declaration consists of the attribute name and optionally its ellipsis
depth (zero if not explicitly specified).

If the attributes are not explicitly listed, they are inferred as the
set of all @tech{pattern variables} occurring in every variant of the
syntax class. Pattern variables that occur at different ellipsis
depths are not included, nor are nested attributes from
@tech{annotated pattern variables}.
}

@specsubform[(code:line #:description description-expr)
             #:contracts ([description-expr (or/c string? #f)])]{

The @scheme[description] argument is evaluated in a scope containing
the syntax class's parameters. If the result is a string, it is used
in error messages involving the syntax class. For example, if a term
is rejected by the syntax class, an error of the form
@schemevalfont{"expected @scheme[description]"} may be synthesized. If
the result is @scheme[#f], the syntax class is skipped in the search
for a description to report.

If the option is not given absent, the name of the syntax class is
used instead.
}

@specsubform[#:opaque]{

Indicates that errors should not be reported with respect to the
internal structure of the syntax class.
}

@specsubform[#:commit]{

Directs the syntax class to ``commit'' to the first successful
match. When a variant succeeds, all choice points within the syntax
class are discarded. See also @scheme[~commit].
}

@specsubform[#:no-delimit-cut]{

By default, a cut (@scheme[~!]) within a syntax class only discards
choice points within the syntax class. That is, the body of the syntax
class acts as though it is wrapped in a @scheme[~delimit-cut] form. If
@scheme[#:no-delimit-cut] is specified, a cut may affect choice points
of the syntax class's calling context (another syntax class's patterns
or a @scheme[syntax-parse] form).

It is an error to use both @scheme[#:commit] and
@scheme[#:no-delimit-cut].
}

@specsubform[(code:line #:literals (literal-entry))]
@specsubform[(code:line #:literal-sets (literal-set ...))]
@specsubform[(code:line #:conventions (convention-id ...))]{

Declares the literals and conventions that apply to the syntax class's
variant patterns and their immediate @scheme[#:with] clauses. Patterns
occuring within subexpressions of the syntax class (for example, on
the right-hand side of a @scheme[#:fail-when] clause) are not
affected.

These options have the same meaning as in @scheme[syntax-parse].
}

Each variant of a syntax class is specified as a separate
@scheme[pattern]-form whose syntax pattern is a @tech{single-term
pattern}.
}

@defform*[#:literals (pattern)
          [(define-splicing-syntax-class name-id stxclass-option ...
             stxclass-variant ...+)
           (define-splicing-syntax-class (name-id kw-formals) stxclass-option ... 
             stxclass-variant ...+)]]{

Defines @scheme[name-id] as a @deftech{splicing syntax class},
analogous to a @tech{syntax class} but encapsulating @tech{head
patterns} rather than @tech{single-term patterns}.

The options are the same as for @scheme[define-syntax-class].

Each variant of a splicing syntax class is specified as a separate
@scheme[pattern]-form whose syntax pattern is a @tech{head pattern}.
}

@defform[#:literals (pattern)
         (pattern syntax-pattern pattern-directive ...)]{

Used to indicate a variant of a syntax class or splicing syntax
class. The variant accepts syntax matching the given syntax pattern
with the accompanying @tech{pattern directives}.

When used within @scheme[define-syntax-class], @scheme[syntax-pattern]
should be a @tech{single-term pattern}; within
@scheme[define-splicing-syntax-class], it should be a @tech{head
pattern}.

The attributes of the variant are the attributes of the pattern
together with all attributes bound by @scheme[#:with] clauses,
including nested attributes produced by syntax classes associated with
the pattern variables.
}

@;{--------}

@section{Pattern directives}

Both the parsing forms and syntax class definition forms support
@deftech{pattern directives} for annotating syntax patterns and
specifying side conditions. The grammar for pattern directives
follows:

@schemegrammar[pattern-directive
               (code:line #:declare pattern-id syntax-class-id)
               (code:line #:declare pattern-id (syntax-class-id arg ...))
               (code:line #:with syntax-pattern expr)
               (code:line #:attr attr-arity-decl expr)
               (code:line #:fail-when condition-expr message-expr)
               (code:line #:fail-unless condition-expr message-expr)
               (code:line #:when condition-expr)
               (code:line #:do [def-or-expr ...])]

@specsubform[(code:line #:declare pvar-id syntax-class-id)]
@specsubform[(code:line #:declare pvar-id (syntax-class-id arg ...))]{

The first form is equivalent to using the
@svar[pvar-id:syntax-class-id] form in the pattern (but it is illegal
to use both for the same pattern variable).

The second form allows the use of parameterized syntax classes, which
cannot be expressed using the ``colon'' notation. The @scheme[arg]s
are evaluated outside the scope of any of the attribute bindings from
pattern that the @scheme[#:declare] directive applies to. Keyword
arguments are supported, using the same syntax as in @scheme[#%app].
}

@specsubform[(code:line #:with syntax-pattern stx-expr)]{

Evaluates the @scheme[stx-expr] in the context of all previous
attribute bindings and matches it against the pattern. If the match
succeeds, the pattern's attributes are added to environment for the
evaluation of subsequent side conditions. If the @scheme[#:with] match
fails, the matching process backtracks. Since a syntax object may
match a pattern in several ways, backtracking may cause the same
clause to be tried multiple times before the next clause is reached.
}

@specsubform[(code:line #:attr attr-arity-decl expr)]{

Evaluates the @scheme[expr] in the context of all previous attribute
bindings and binds it to the given attribute. The value of
@scheme[expr] need not be syntax.
}

@specsubform[(code:line #:fail-when condition-expr message-expr)
             #:contracts ([message-expr (or/c string? #f)])]{

Evaluates the @scheme[condition-expr] in the context of all previous
attribute bindings. If the value is any true value (not @scheme[#f]),
the matching process backtracks (with the given message); otherwise,
it continues. If the value of the condition expression is a syntax
object, it is indicated as the cause of the error.

If the @scheme[message-expr] produces a string it is used as the
failure message; otherwise the failure is reported in terms of the
enclosing descriptions.
}

@specsubform[(code:line #:fail-unless condition-expr message-expr)
             #:contracts ([message-expr (or/c string? #f)])]{

Like @scheme[#:fail-when] with the condition negated.
}

@specsubform[(code:line #:when condition-expr)]{

Evaluates the @scheme[condition-expr] in the context of all previous
attribute bindings. If the value is @scheme[#f], the matching process
backtracks. In other words, @scheme[#:when] is like
@scheme[#:fail-unless] without the message argument.
}

@specsubform[(code:line #:do [def-or-expr ...])]{

Takes a sequence of definitions and expressions, which may be
intermixed, and evaluates them in the scope of all previous attribute
bindings. The names bound by the definitions are in scope in
the expressions of subsequent patterns and clauses.

There is currently no way to bind attributes using a @scheme[#:do]
block. It is an error to shadow an attribute binding with a definition
in a @scheme[#:do] block.
}


@;{----------}

@section{Pattern variables and attributes}

An @deftech{attribute} is a name bound by a syntax pattern. An
attribute can be a @tech{pattern variable} itself, or it can be a
@tech{nested attribute} bound by an @tech{annotated pattern
variable}. The name of a nested attribute is computed by concatenating
the pattern variable name with the syntax class's exported attribute's
name, separated by a dot (see the example below).

Attribute names cannot be used directly as expressions; that is,
attributes are not variables. Instead, an attribute's value can be
gotten using the @scheme[attribute] special form.

@defform[(attribute attr-id)]{

Returns the value associated with the attribute named
@scheme[attr-id]. If @scheme[attr-id] is not bound as an attribute, an
error is raised.
}

The value of an attribute need not be syntax. Non-syntax-valued
attributes can be used to return a parsed representation of a subterm
or the results of an analysis on the subterm. A non-syntax-valued
attribute should be bound using the @scheme[#:attr] directive or a
@scheme[~bind] pattern.

@myexamples[
(define-syntax-class table
  (pattern ((key value) ...)
           #:attr hash
                  (for/hash ([k (syntax->datum #'(key ...))]
                             [v (syntax->datum #'(value ...))])
                    (values k v))))
(syntax-parse #'((a 1) (b 2) (c 3))
  [t:table
   (attribute t.hash)])
]

A syntax-valued attribute is an attribute whose value is a syntax
object or a syntax list of the appropriate @tech{ellipsis
depth}. Syntax-valued attributes can be used within @scheme[syntax],
@scheme[quasisyntax], etc as part of a syntax template. If a
non-syntax-valued attribute is used in a syntax template, a runtime
error is signalled.

@myexamples[
(syntax-parse #'((a 1) (b 2) (c 3))
  [t:table
   #'(t.key ...)])
(syntax-parse #'((a 1) (b 2) (c 3))
  [t:table
   #'t.hash])
]

Every attribute has an associated @deftech{ellipsis depth} that
determines how it can be used in a syntax template (see the discussion
of ellipses in @scheme[syntax]). For a pattern variable, the ellipsis
depth is the number of ellipses the pattern variable ``occurs under''
in the pattern. For a nested attribute the depth is the sum of the
pattern variable's depth and the depth of the attribute in the syntax
class. Consider the following code:

@schemeblock[
(define-syntax-class quark
  (pattern (a b ...)))
(syntax-parse some-term
  [(x (y:quark ...) ... z:quark)
   some-code])
]

The syntax class @scheme[quark] exports two attributes: @scheme[a] at
depth 0 and @scheme[b] at depth 1. The @scheme[syntax-parse] pattern
has three pattern variables: @scheme[x] at depth 0, @scheme[y] at
depth 2, and @scheme[z] at depth 0. Since @scheme[x] and @scheme[y]
are annotated with the @scheme[quark] syntax class, the pattern also
binds the following nested attributes: @scheme[y.a] at depth 2,
@scheme[y.b] at depth 3, @scheme[z.a] at depth 0, and @scheme[z.b] at
depth 1.

An attribute's ellipsis nesting depth is @emph{not} a guarantee that
its value has that level of list nesting. In particular, @scheme[~or]
and @scheme[~optional] patterns may result in attributes with fewer
than expected levels of list nesting.

@(myexamples
  (syntax-parse #'(1 2 3)
    [(~or (x:id ...) _)
     (attribute x)]))
