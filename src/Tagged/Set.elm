module Tagged.Set exposing (..)

{-| A module that allows tagging sets, while maintaining an API parallel to `Set`.

A common idea is wanting to store a value that is not `comparable` in `Set a`.
Since we can't currently do that there are many different ways to address the problem.
One way to solve that problem is to use a type level assertion.

Rather than holding on to an entirely different type for the values and threading a comparison function through,
we can just tell elm that we'd like to tag the `Set a` at compile time.
Doing so allows us to reuse the underlying behavior of the `Set a` with very little runtime overhead.
Most functions here are simple wrappers to refine the types without modifying the values.

@docs TaggedSet


# Build

@docs empty, singleton, insert, remove


# Query

@docs isEmpty, member, size


# Lists

@docs toUntaggedList, fromUntaggedList, toList, fromList


# Transform

@docs map, foldl, foldr, filter, partition


# Combine

@docs union, intersect, diff

-}

import Set exposing (Set)
import Tagged exposing (..)


{-| A set that tags the values with an additional constraint.

The constraint is phantom in that it doesn't show up at runtime.

-}
type alias TaggedSet a comparable =
    Tagged a (Set comparable)


{-| Create an empty set.
-}
empty : TaggedSet k comparable
empty =
    tag Set.empty


{-| Create a set with one value.
-}
singleton : Tagged k comparable -> TaggedSet k comparable
singleton =
    tag << Set.singleton << untag


{-| Insert a value pair into a set.
-}
insert : Tagged k comparable -> TaggedSet k comparable -> TaggedSet k comparable
insert =
    Tagged.map << Set.insert << untag


{-| Remove a value from a set. If the value is not found, no changes are made.
-}
remove : Tagged k comparable -> TaggedSet k comparable -> TaggedSet k comparable
remove =
    Tagged.map << Set.remove << untag


{-| Determine if a set is empty.
-}
isEmpty : TaggedSet k c -> Bool
isEmpty =
    Set.isEmpty << untag


{-| Determine if a value is in a set.
-}
member : Tagged k comparable -> TaggedSet k comparable -> Bool
member k =
    Set.member (untag k) << untag


{-| Determine the number of values in a set.
-}
size : TaggedSet k c -> Int
size =
    Set.size << untag


{-| Convert a set into a sorted list of untagged values.
-}
toUntaggedList : TaggedSet k comparable -> List comparable
toUntaggedList =
    Set.toList << untag


{-| Convert an untagged list into a set.
-}
fromUntaggedList : List comparable -> TaggedSet k comparable
fromUntaggedList =
    tag << Set.fromList


{-| Convert a set into a sorted list of tagged values.
-}
toList : TaggedSet k comparable -> List (Tagged k comparable)
toList =
    List.map (\c -> tag c) << toUntaggedList


{-| Convert a list into a set.
-}
fromList : List (Tagged k comparable) -> TaggedSet k comparable
fromList =
    fromUntaggedList << List.map (\c -> untag c)


{-| Apply a function to all values in a set.
-}
map :
    (Tagged k comparable -> comparable2)
    -> TaggedSet k comparable
    -> TaggedSet k comparable2
map f =
    Tagged.map (Set.map (f << tag))


{-| Fold over the values in a set, in order from lowest value to highest value.
-}
foldl :
    (Tagged k comparable -> b -> b)
    -> b
    -> TaggedSet k comparable
    -> b
foldl f z =
    Set.foldl (f << tag) z << untag


{-| Fold over the values in a set, in order from highest value to lowest value.
-}
foldr :
    (Tagged k comparable -> b -> b)
    -> b
    -> TaggedSet k comparable
    -> b
foldr f z =
    Set.foldr (f << tag) z << untag


{-| Create a new set consisting only of elements which satisfy a predicate.
-}
filter :
    (Tagged k comparable -> Bool)
    -> TaggedSet k comparable
    -> TaggedSet k comparable
filter f =
    Tagged.map (Set.filter (f << tag))


{-| Create two new sets; the first consisting of elements which satisfy a predicate, the second consisting of elements which do not.
-}
partition :
    (Tagged k comparable -> Bool)
    -> TaggedSet k comparable
    -> ( TaggedSet k comparable, TaggedSet k comparable )
partition f set =
    let
        ( set1, set2 ) =
            Set.partition (f << tag) (untag set)
    in
    ( tag set1, tag set2 )


{-| Get the union of two sets. Keep all values.
-}
union :
    TaggedSet k comparable
    -> TaggedSet k comparable
    -> TaggedSet k comparable
union =
    Tagged.map2 Set.union


{-| Get the intersection of two sets. Keeps values that appear in both sets.
-}
intersect :
    TaggedSet k comparable
    -> TaggedSet k comparable
    -> TaggedSet k comparable
intersect =
    Tagged.map2 Set.intersect


{-| Get the difference between the first set and the second. Keeps values that do not appear in the second set.
-}
diff :
    TaggedSet k comparable
    -> TaggedSet k comparable
    -> TaggedSet k comparable
diff =
    Tagged.map2 Set.diff
