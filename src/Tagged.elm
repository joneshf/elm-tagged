module Tagged exposing (..)

{-| A module that allows you to "tag" a value.

@docs Tagged, tag, retag, untag, map, ap, map2, bind, extend

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


{-| Useful for composing functions together in a pipeline:

    foo =
        Array.set |> map index |> ap value |> ap arr

-}
map : (oldValue -> newValue) -> Tagged tag oldValue -> Tagged tag newValue
map f (Tagged x) =
    Tagged (f x)


{-| Useful for composing functions together in a pipeline:

    foo =
        Array.set |> map index |> ap value |> ap arr

-}
ap : Tagged tag (oldValue -> newValue) -> Tagged tag oldValue -> Tagged tag newValue
ap (Tagged f) (Tagged x) =
    Tagged (f x)


{-| An alternative to `ap`:

    foo =
        map2 Array.get index arr

-}
map2 : (a -> b -> c) -> Tagged tag a -> Tagged tag b -> Tagged tag c
map2 f t1 t2 =
    ap (map f t1) t2


{-| Useful for restricting the tag created in a polymorphic function.
-}
bind : (oldValue -> Tagged tag newValue) -> Tagged tag oldValue -> Tagged tag newValue
bind f (Tagged x) =
    f x


{-| Useful when you have a function that throws away a tag prematurely,
but you still need the tag later.
-}
extend : (Tagged tag oldValue -> newValue) -> Tagged tag oldValue -> Tagged tag newValue
extend f x =
    tag (f x)


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
