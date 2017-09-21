# elm-tagged

[![Build Status](https://travis-ci.org/joneshf/elm-tagged.svg?branch=master)](https://travis-ci.org/joneshf/elm-tagged)

A library that allows you to "tag" a value with a specific type for compile time verification.

The semantics associated with the value do not change.
If you had an `Int`, `Maybe Bool`, or `List String` before,
it's still an `Int`, `Maybe Bool`, or `List String` respectively.
It just now has a type level tag.

Tagging a value is useful for making compile time assertions about what you're building.
For instance, let's say you are modeling two resources from a server `User` and `Comment`.
Both of these resources have unique identifiers which could be represented as `Int`s.

We might have the following:

```elm
type alias User =
  { ident : Int
  , ...
  }

type alias Comment =
  { ident : Int
  , ...
  }
```

Although the two are very similar,
a `User` identifier should not be used in the same way as a `Comment` identifier.

Since these two records use the same underlying type for their `ident` fields,
the type checker wont stop you from using a `User` identifier where a `Comment` identifier was expected.

A first pass at making this distinction might be to give each identifier a type alias.

```elm
type alias UserIdent =
  Int

type alias User =
  { ident : UserIdent
  , ...
  }

type alias CommentIdent =
  Int

type alias Comment =
  { ident : CommentIdent
  , ...
  }
```

Now you as a human can tell a little better that the two identifiers are different.
However, the type checker still wont stop you from using a `User` identifier where a `Comment` identifier was expected.

A second pass at making this distinction might be to give each identifier its own type.

```elm
type UserIdent
  = UserIdent Int

type alias User =
  { ident : UserIdent
  , ...
  }

type CommentIdent
  = CommentIdent Int

type alias Comment =
  { ident : CommentIdent
  , ...
  }
```

Now you as a human can tell a little better that the two identifiers are different.
And, the type checker **WILL** stop you from using a `User` identifier where a `Comment` identifier was expected!

However, note that now operations like `(<)` don't work with `UserIdent` and `CommentIdent`.

So you might write a function for that.

```elm
type UserIdent
  = UserIdent Int

type alias User =
  { ident : UserIdent
  , ...
  }

ltUserIdent : UserIdent -> UserIdent -> Bool
ltUserIdent (UserIdent x) (UserIdent y) =
  x < y

type CommentIdent
  = CommentIdent Int

type alias Comment =
  { ident : CommentIdent
  , ...
  }

ltCommentIdent : CommentIdent -> CommentIdent -> Bool
ltCommentIdent (CommentIdent x) (CommentIdent y) =
  x < y
```

Next, you might find out that you need `(<=)` to work as well for each identifier.
So, you write another function.

```elm
type UserIdent
  = UserIdent Int

type alias User =
  { ident : UserIdent
  , ...
  }

ltUserIdent : UserIdent -> UserIdent -> Bool
ltUserIdent (UserIdent x) (UserIdent y) =
  x < y

gteUserIdent : UserIdent -> UserIdent -> Bool
gteUserIdent (UserIdent x) (UserIdent y) =
  x >= y

type CommentIdent
  = CommentIdent Int

type alias Comment =
  { ident : CommentIdent
  , ...
  }

ltCommentIdent : CommentIdent -> CommentIdent -> Bool
ltCommentIdent (CommentIdent x) (CommentIdent y) =
  x < y

gteCommentIdent : CommentIdent -> CommentIdent -> Bool
gteCommentIdent (CommentIdent x) (CommentIdent y) =
  x >= y
```

And then you might write another function, and another.
Usually one of two things happens.
You either end up writing a slew of boilerplate functions,
or you lie to yourself (and your team if you're working with others)
and say that expressing these constraints isn't important/worth the time.

If you continue down the first path,
you might recognize a pattern that all of these functions have in common:
they are all unwrapping the "tag", applying the function and wrapping the value back up in the "tag".

This module abstracts away the pattern so you don't have to spend time writing the same code over and over.

The key insight is that `UserIdent` and `CommentIdent` are structurally the same.
They both wrap a type—`Int`—with a "tag"—`UserIdent` or `CommentIdent`.
So what we want is a type that carries another type and a "tag":

```elm
type Tagged tag value
  = ...
```

Now, what values does this type need to provide?
At runtime, we don't care about what type the value was tagged with.
We just care about the value itself.
So, let's only provide the value:

```elm
type Tagged tag value
  = Tagged value
```

And how does this work for our running example?
Well, we need to create a "tag" for `UserIdent` and a "tag" for `CommentIdent`.

```elm
-- It'd be nice if we could just say `type UserIdent`, but elm can't parse that.
type UserIdent
  = UserIdent

type alias User =
  { ident : Tagged UserIdent Int
  , ...
  }

-- It'd be nice if we could just say `type CommentIdent`, but elm can't parse that.
type CommentIdent
  = CommentIdent

type alias Comment =
  { ident : Tagged CommentIdent Int
  , ...
  }
```

If we need to compare `UserIdent`s,
we can use `Tagged` functions rather than needing to rewrite everything.

```elm
Tagged.map2 (<) someIdent anotherIdent
```
