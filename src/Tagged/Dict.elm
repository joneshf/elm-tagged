module Tagged.Dict
    exposing
        ( TaggedDict
        , diff
        , empty
        , filter
        , foldl
        , foldr
        , fromList
        , fromUntaggedList
        , get
        , insert
        , intersect
        , isEmpty
        , keys
        , map
        , member
        , merge
        , partition
        , remove
        , singleton
        , size
        , toList
        , toUntaggedList
        , union
        , untaggedKeys
        , update
        , values
        )

{-| A module that allows tagging dictionaries, while maintaining an API parallel to `Dict`.

A common idea is wanting to use a value that is not `comparable` as the key of a `Dict a b`.
Since we can't currently do that there are many different ways to address the problem.
One way to solve that problem is to use a type level assertion.

Rather than holding on to an entirely different type in the keys and threading a comparison function through,
we can just tell elm that we'd like to tag the `Dict a b` at compile time.
Doing so allows us to reuse the underlying behavior of the `Dict a b` with very little runtime overhead.
Most functions here are simple wrappers to refine the types without modifying the values.

@docs TaggedDict


# Build

@docs empty, singleton, insert, update, remove


# Query

@docs isEmpty, member, get, size


# Lists

@docs untaggedKeys, keys, values, toUntaggedList, fromUntaggedList, toList, fromList


# Transform

@docs map, foldl, foldr, filter, partition


# Combine

@docs union, intersect, diff, merge

-}

import Dict exposing (Dict)
import Tagged exposing (..)


{-| A dictionary that tags the keys with an additional constraint.

The constraint is phantom in that it doesn't show up at runtime.

-}
type alias TaggedDict a b c =
    Tagged a (Dict b c)


{-| Create an empty dictionary.
-}
empty : TaggedDict tag comparable v
empty =
    tag Dict.empty


{-| Create a dictionary with one key-value pair.
-}
singleton : Tagged tag comparable -> v -> TaggedDict tag comparable v
singleton k =
    tag << Dict.singleton (untag k)


{-| Insert a key-value pair into a dictionary. Replaces value when there is a collision.
-}
insert : Tagged tag comparable -> v -> TaggedDict tag comparable v -> TaggedDict tag comparable v
insert k =
    Tagged.map << Dict.insert (untag k)


{-| Update the value of a dictionary for a specific key with a given function.
-}
update : Tagged tag comparable -> (Maybe v -> Maybe v) -> TaggedDict tag comparable v -> TaggedDict tag comparable v
update k =
    Tagged.map << Dict.update (untag k)


{-| Remove a key-value pair from a dictionary. If the key is not found, no changes are made.
-}
remove : Tagged tag comparable -> TaggedDict tag comparable v -> TaggedDict tag comparable v
remove =
    Tagged.map << Dict.remove << untag


{-| Determine if a dictionary is empty.
-}
isEmpty : TaggedDict tag c v -> Bool
isEmpty =
    Dict.isEmpty << untag


{-| Determine if a key is in a dictionary.
-}
member : Tagged tag comparable -> TaggedDict tag comparable v -> Bool
member k =
    Dict.member (untag k) << untag


{-| Get the value associated with a key.
-}
get : Tagged tag comparable -> TaggedDict tag comparable v -> Maybe v
get k =
    Dict.get (untag k) << untag


{-| Determine the number of key-value pairs in the dictionary.
-}
size : TaggedDict tag c v -> Int
size =
    Dict.size << untag


{-| Get all of the untagged keys in a dictionary, sorted from lowest to highest.
-}
untaggedKeys : TaggedDict tag comparable v -> List comparable
untaggedKeys =
    Dict.keys << untag


{-| Get all of the keys in a dictionary, sorted from lowest to highest.
-}
keys : TaggedDict tag comparable v -> List (Tagged tag comparable)
keys =
    List.map tag << untaggedKeys


{-| Get all of the values in a dictionary, in the order of their keys.
-}
values : TaggedDict tag comparable v -> List v
values =
    Dict.values << untag


{-| Convert a dictionary into an association list of untagged key-value pairs, sorted by keys.
-}
toUntaggedList : TaggedDict tag comparable v -> List ( comparable, v )
toUntaggedList =
    Dict.toList << untag


{-| Convert an untagged association list into a dictionary.
-}
fromUntaggedList : List ( comparable, v ) -> TaggedDict tag comparable v
fromUntaggedList =
    tag << Dict.fromList


{-| Convert a dictionary into an association list of key-value pairs, sorted by keys.
-}
toList : TaggedDict tag comparable v -> List ( Tagged tag comparable, v )
toList =
    List.map (\( c, v ) -> ( tag c, v )) << toUntaggedList


{-| Convert an association list into a dictionary.
-}
fromList : List ( Tagged tag comparable, v ) -> TaggedDict tag comparable v
fromList =
    fromUntaggedList << List.map (\( k, v ) -> ( untag k, v ))


{-| Apply a function to all values in a dictionary.
-}
map :
    (Tagged tag comparable -> a -> b)
    -> TaggedDict tag comparable a
    -> TaggedDict tag comparable b
map f =
    Tagged.map (Dict.map (f << tag))


{-| Fold over the key-value pairs in a dictionary, in order from lowest key to highest key.
-}
foldl :
    (Tagged tag comparable -> v -> b -> b)
    -> b
    -> TaggedDict tag comparable v
    -> b
foldl f z =
    Dict.foldl (f << tag) z << untag


{-| Fold over the key-value pairs in a dictionary, in order from highest key to lowest key.
-}
foldr :
    (Tagged tag comparable -> v -> b -> b)
    -> b
    -> TaggedDict tag comparable v
    -> b
foldr f z =
    Dict.foldr (f << tag) z << untag


{-| Keep a key-value pair when it satisfies a predicate.
-}
filter :
    (Tagged tag comparable -> v -> Bool)
    -> TaggedDict tag comparable v
    -> TaggedDict tag comparable v
filter f =
    Tagged.map (Dict.filter (f << tag))


{-| Partition a dictionary according to a predicate. The first dictionary contains all key-value pairs which satisfy the predicate, and the second contains the rest.
-}
partition :
    (Tagged tag comparable -> v -> Bool)
    -> TaggedDict tag comparable v
    -> ( TaggedDict tag comparable v, TaggedDict tag comparable v )
partition f dict =
    let
        ( dict1, dict2 ) =
            Dict.partition (f << tag) (untag dict)
    in
    ( tag dict1, tag dict2 )


{-| Combine two dictionaries. If there is a collision, preference is given to the first dictionary.
-}
union :
    TaggedDict tag comparable v
    -> TaggedDict tag comparable v
    -> TaggedDict tag comparable v
union =
    Tagged.map2 Dict.union


{-| Keep a key-value pair when its key appears in the second dictionary. Preference is given to values in the first dictionary.
-}
intersect :
    TaggedDict tag comparable v
    -> TaggedDict tag comparable v
    -> TaggedDict tag comparable v
intersect =
    Tagged.map2 Dict.intersect


{-| Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff :
    TaggedDict tag comparable v
    -> TaggedDict tag comparable v
    -> TaggedDict tag comparable v
diff =
    Tagged.map2 Dict.diff


{-| The most general way of combining two dictionaries.
-}
merge :
    (Tagged tag comparable -> a -> result -> result)
    -> (Tagged tag comparable -> a -> b -> result -> result)
    -> (Tagged tag comparable -> b -> result -> result)
    -> TaggedDict tag comparable a
    -> TaggedDict tag comparable b
    -> result
    -> result
merge f g h dict1 dict2 =
    Dict.merge (f << tag) (g << tag) (h << tag) (untag dict1) (untag dict2)
