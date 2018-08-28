module Tagged
    exposing
        ( Tagged(..)
        , andMap
        , andThen
        , ap
        , bind
        , extend
        , map
        , map2
        , retag
        , tag
        , untag
        )

{-| A module that allows you to "tag" a value.

@docs Tagged
@docs tag
@docs retag
@docs untag
@docs map
@docs ap
@docs map2
@docs andMap
@docs bind
@docs andThen
@docs extend

-}


{-| A Type that pairs a `value` with a `tag`.

The `tag` is ignored at runtime as evidenced by the only value constructor:

    Tagged : value -> Tagged tag value

-}
type Tagged tag value
    = Tagged value


{-| An alias for the `Tagged` value constructor.
-}
tag : value -> Tagged tag value
tag =
    Tagged


{-| Useful for applying a function on a `Tagged` value.

    foo =
        map String.toUpper aTaggedString

-}
map : (oldValue -> newValue) -> Tagged tag oldValue -> Tagged tag newValue
map f (Tagged x) =
    Tagged (f x)


{-| Useful for building more useful functions:

    map f =
        ap (Tagged f)

    map2 f x =
        ap (map f x)

    map3 f x y =
        ap (map2 f x y)

-}
ap : Tagged tag (oldValue -> newValue) -> Tagged tag oldValue -> Tagged tag newValue
ap (Tagged f) (Tagged x) =
    Tagged (f x)


{-| Useful for composing functions together in a pipeline:

    foo =
        Tagged Array.set
            |> andMap index
            |> andMap value
            |> andMap arr

-}
andMap : Tagged tag oldValue -> Tagged tag (oldValue -> newValue) -> Tagged tag newValue
andMap (Tagged x) (Tagged f) =
    Tagged (f x)


{-| An alternative to `ap`:

    foo =
        map2 Array.get index arr

-}
map2 : (a -> b -> c) -> Tagged tag a -> Tagged tag b -> Tagged tag c
map2 f (Tagged x) (Tagged y) =
    Tagged (f x y)


{-| Useful for restricting the tag created in a polymorphic function.
-}
andThen : (oldValue -> Tagged tag newValue) -> Tagged tag oldValue -> Tagged tag newValue
andThen f (Tagged x) =
    f x


{-| Useful for restricting the tag created in a polymorphic function.
-}
bind : Tagged tag oldValue -> (oldValue -> Tagged tag newValue) -> Tagged tag newValue
bind (Tagged x) f =
    f x


{-| Useful when you have a function that throws away a tag prematurely,
but you still need the tag later.
-}
extend : (Tagged tag oldValue -> newValue) -> Tagged tag oldValue -> Tagged tag newValue
extend f x =
    Tagged (f x)


{-| Explicitly changes the tag of a value.

Forces you to recognize that the value is being interpreted differently from before.

-}
retag : Tagged oldTag value -> Tagged newTag value
retag (Tagged x) =
    Tagged x


{-| We can remove the tag when we're done making additional compile-time assertions.
-}
untag : Tagged tag value -> value
untag (Tagged x) =
    x
