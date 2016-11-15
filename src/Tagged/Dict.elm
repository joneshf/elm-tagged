module Tagged.Dict exposing (..)

{-|

A module that allows tagging dictionaries.

A common idea is wanting to use a value that is not `comparable` as the key of a `Dict a b`.
Since we can't currently do that there are many different ways to address the problem.
One way to solve that problem is to use a type level assertion.

Rather than holding on to an entirely different type in the keys and threading a comparison function through,
we can just tell elm that we'd like to tag the `Dict a b` at compile time.
Doing so allows us to reuse the underlying behavior of the `Dict a b` with very little runtime overhead.
Most functions here are simple wrappers to refine the types without modifying the values.

@docs TaggedDict

# Build

@docs empty, singleton, insert

# Query

@docs update, remove, isEmpty, member, get, size

# Lists

@docs untaggedKeys, keys, values, toUntaggedList, fromUntaggedList, toList, fromList

# Transform

@docs map, foldl, foldr, filter, partition

# Combine
@docs union, intersect, diff, merge
-}
import Dict exposing (Dict)
import Tagged exposing (..)


{-|
A dictionary that tags the keys with an additional constraint.

The constraint is phantom in that it doesn't show up at runtime.
-}
type TaggedDict a b c
    = TaggedDict (Dict b c)


{-|
Create an empty dictionary.
-}
empty : TaggedDict k comparable v
empty =
    TaggedDict Dict.empty


{-|
Create a dictionary with one key-value pair.
-}
singleton : Tagged k comparable -> v -> TaggedDict k comparable v
singleton k v =
    TaggedDict (Dict.singleton (untag k) v)


{-|
Insert a key-value pair into a dictionary. Replaces value when there is a collision.
-}
insert : Tagged k comparable -> v -> TaggedDict k comparable v -> TaggedDict k comparable v
insert k v (TaggedDict dict) =
    TaggedDict (Dict.insert (untag k) v dict)


{-|
Update the value of a dictionary for a specific key with a given function.
-}
update : Tagged k comparable -> (Maybe v -> Maybe v) -> TaggedDict k comparable v -> TaggedDict k comparable v
update k f (TaggedDict dict) =
    TaggedDict (Dict.update (untag k) f dict)


{-|
Remove a key-value pair from a dictionary. If the key is not found, no changes are made.
-}
remove : Tagged k comparable -> TaggedDict k comparable v -> TaggedDict k comparable v
remove k (TaggedDict dict) =
    TaggedDict (Dict.remove (untag k) dict)


{-|
Determine if a dictionary is empty.
-}
isEmpty : TaggedDict k c v -> Bool
isEmpty (TaggedDict dict) =
    Dict.isEmpty dict


{-|
Determine if a key is in a dictionary.
-}
member : Tagged k comparable -> TaggedDict k comparable v -> Bool
member k (TaggedDict dict) =
    Dict.member (untag k) dict


{-|
Get the value associated with a key.
-}
get : Tagged k comparable -> TaggedDict k comparable v -> Maybe v
get k (TaggedDict dict) =
    Dict.get (untag k) dict


{-|
Determine the number of key-value pairs in the dictionary.
-}
size : TaggedDict k c v -> Int
size (TaggedDict dict) =
    Dict.size dict


{-|
Get all of the untagged keys in a dictionary, sorted from lowest to highest.
-}
untaggedKeys : TaggedDict k comparable v -> List comparable
untaggedKeys (TaggedDict dict) =
    Dict.keys dict


{-|
Get all of the keys in a dictionary, sorted from lowest to highest.
-}
keys : TaggedDict k comparable v -> List (Tagged k comparable)
keys (TaggedDict dict) =
    List.map tag (Dict.keys dict)


{-|
Get all of the values in a dictionary, in the order of their keys.
-}
values : TaggedDict k comparable v -> List v
values (TaggedDict dict) =
    Dict.values dict


{-|
Convert a dictionary into an association list of untagged key-value pairs, sorted by keys.
-}
toUntaggedList : TaggedDict k comparable v -> List ( comparable, v )
toUntaggedList (TaggedDict dict) =
    Dict.toList dict


{-|
Convert an untagged association list into a dictionary.
-}
fromUntaggedList : List ( comparable, v ) -> TaggedDict k comparable v
fromUntaggedList list =
    TaggedDict (Dict.fromList list)


{-|
Convert a dictionary into an association list of key-value pairs, sorted by keys.
-}
toList : TaggedDict k comparable v -> List ( Tagged k comparable, v )
toList (TaggedDict dict) =
    List.map (\( c, v ) -> ( tag c, v )) (Dict.toList dict)


{-|
Convert an association list into a dictionary.
-}
fromList : List ( Tagged k comparable, v ) -> TaggedDict k comparable v
fromList list =
    TaggedDict (Dict.fromList (List.map (\( k, v ) -> ( untag k, v )) list))


{-|
Apply a function to all values in a dictionary.
-}
map :
    (Tagged k comparable -> a -> b)
    -> TaggedDict k comparable a
    -> TaggedDict k comparable b
map f (TaggedDict dict) =
    TaggedDict (Dict.map (f << tag) dict)


{-|
Fold over the key-value pairs in a dictionary, in order from lowest key to highest key.
-}
foldl :
    (Tagged k comparable -> v -> b -> b)
    -> b
    -> TaggedDict k comparable v
    -> b
foldl f z (TaggedDict dict) =
    Dict.foldl (f << tag) z dict


{-|
Fold over the key-value pairs in a dictionary, in order from highest key to lowest key.
-}
foldr :
    (Tagged k comparable -> v -> b -> b)
    -> b
    -> TaggedDict k comparable v
    -> b
foldr f z (TaggedDict dict) =
    Dict.foldr (f << tag) z dict


{-|
Keep a key-value pair when it satisfies a predicate.
-}
filter :
    (Tagged k comparable -> v -> Bool)
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
filter f (TaggedDict dict) =
    TaggedDict (Dict.filter (f << tag) dict)


{-|
Partition a dictionary according to a predicate. The first dictionary contains all key-value pairs which satisfy the predicate, and the second contains the rest.
-}
partition :
    (Tagged k comparable -> v -> Bool)
    -> TaggedDict k comparable v
    -> ( TaggedDict k comparable v, TaggedDict k comparable v )
partition f (TaggedDict dict) =
    let
        ( x, y ) =
            Dict.partition (f << tag) dict
    in
        ( TaggedDict x, TaggedDict y )


{-|
Combine two dictionaries. If there is a collision, preference is given to the first dictionary.
-}
union :
    TaggedDict k comparable v
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
union (TaggedDict dict1) (TaggedDict dict2) =
    TaggedDict (Dict.union dict1 dict2)


{-|
Keep a key-value pair when its key appears in the second dictionary. Preference is given to values in the first dictionary.
-}
intersect :
    TaggedDict k comparable v
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
intersect (TaggedDict dict1) (TaggedDict dict2) =
    TaggedDict (Dict.intersect dict1 dict2)


{-|
Keep a key-value pair when its key does not appear in the second dictionary.
-}
diff :
    TaggedDict k comparable v
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
diff (TaggedDict dict1) (TaggedDict dict2) =
    TaggedDict (Dict.diff dict1 dict2)


{-|
The most general way of combining two dictionaries.
-}
merge :
    (Tagged k comparable -> a -> result -> result)
    -> (Tagged k comparable -> a -> b -> result -> result)
    -> (Tagged k comparable -> b -> result -> result)
    -> TaggedDict k comparable a
    -> TaggedDict k comparable b
    -> result
    -> result
merge f g h (TaggedDict dict1) (TaggedDict dict2) =
    Dict.merge (f << tag) (g << tag) (h << tag) dict1 dict2
