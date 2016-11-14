module Tagged.Dict exposing (..)

import Dict exposing (Dict)
import Tagged exposing (..)


type TaggedDict a b c
    = TaggedDict (Dict b c)


empty : TaggedDict k comparable v
empty =
    TaggedDict Dict.empty


singleton : Tagged k comparable -> v -> TaggedDict k comparable v
singleton k v =
    TaggedDict (Dict.singleton (untag k) v)


insert : Tagged k comparable -> v -> TaggedDict k comparable v -> TaggedDict k comparable v
insert k v (TaggedDict dict) =
    TaggedDict (Dict.insert (untag k) v dict)


update : Tagged k comparable -> (Maybe v -> Maybe v) -> TaggedDict k comparable v -> TaggedDict k comparable v
update k f (TaggedDict dict) =
    TaggedDict (Dict.update (untag k) f dict)


remove : Tagged k comparable -> TaggedDict k comparable v -> TaggedDict k comparable v
remove k (TaggedDict dict) =
    TaggedDict (Dict.remove (untag k) dict)


isEmpty : TaggedDict t k v -> Bool
isEmpty (TaggedDict dict) =
    Dict.isEmpty dict


member : Tagged k comparable -> TaggedDict k comparable v -> Bool
member k (TaggedDict dict) =
    Dict.member (untag k) dict


get : Tagged k comparable -> TaggedDict k comparable v -> Maybe v
get k (TaggedDict dict) =
    Dict.get (untag k) dict


size : TaggedDict t k v -> Int
size (TaggedDict dict) =
    Dict.size dict


keys : TaggedDict k comparable v -> List comparable
keys (TaggedDict dict) =
    Dict.keys dict


values : TaggedDict k comparable v -> List v
values (TaggedDict dict) =
    Dict.values dict


toList : TaggedDict k comparable v -> List ( comparable, v )
toList (TaggedDict dict) =
    Dict.toList dict


fromList : List ( comparable, v ) -> TaggedDict k comparable v
fromList list =
    TaggedDict (Dict.fromList list)


map :
    (Tagged k comparable -> a -> b)
    -> TaggedDict k comparable a
    -> TaggedDict k comparable b
map f (TaggedDict dict) =
    TaggedDict (Dict.map (f << tag) dict)


foldl :
    (Tagged k comparable -> v -> b -> b)
    -> b
    -> TaggedDict k comparable v
    -> b
foldl f z (TaggedDict dict) =
    Dict.foldl (f << tag) z dict


foldr :
    (Tagged k comparable -> v -> b -> b)
    -> b
    -> TaggedDict k comparable v
    -> b
foldr f z (TaggedDict dict) =
    Dict.foldr (f << tag) z dict


filter :
    (Tagged k comparable -> v -> Bool)
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
filter f (TaggedDict dict) =
    TaggedDict (Dict.filter (f << tag) dict)


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


union :
    TaggedDict k comparable v
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
union (TaggedDict dict1) (TaggedDict dict2) =
    TaggedDict (Dict.union dict1 dict2)


intersect :
    TaggedDict k comparable v
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
intersect (TaggedDict dict1) (TaggedDict dict2) =
    TaggedDict (Dict.intersect dict1 dict2)


diff :
    TaggedDict k comparable v
    -> TaggedDict k comparable v
    -> TaggedDict k comparable v
diff (TaggedDict dict1) (TaggedDict dict2) =
    TaggedDict (Dict.diff dict1 dict2)


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
