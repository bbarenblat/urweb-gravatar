(* Copyright 2015 the Massachusetts Institute of Technology

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License. *)

fun separate_with (sep : string) (xs : list string) : string =
  List.foldr (fn result x => case x of
                                 "" => result
                               | _ => strcat x (strcat sep result))
             ""
             xs

structure Options = struct
  datatype missing_image_response =
      FourOhFour
    | MysteryMan
    | Identicon
    | Monster
    | Wavatar
    | Retro
    | Blank
    | Url of url

  val show_missing_image_response : show missing_image_response =
    mkShow (fn r =>
              case r of
                  FourOhFour => "404"
                | MysteryMan => "mm"
                | Identicon => "identicon"
                | Monster => "monsterid"
                | Wavatar => "wavatar"
                | Retro => "retro"
                | Blank => "blank"
                | Url u => show u)

  datatype rating = G | PG | R | X

  val show_rating : show rating =
    mkShow (fn r =>
              case r of
                  G => "g"
                | PG => "pg"
                | R => "r"
                | X => "x")

  type t = {
      Size : option int,
      Default : option missing_image_response,
      ForceDefault : bool,
      Rating : option rating
    }

  (* Converts a possibly null value to a component in an HTTP query string. *)
  fun parameter_string [a] (show_a : show a)
                       (url_key : string) (value : option a)
                       : string =
    case value of
        None => ""
      | Some v => strcat url_key (strcat "=" (@show show_a v))

  (* Generates a list of the components in the HTTP query string corresponding
  to [options]. *)
  fun query_string_elements (options : t) : list string =
    parameter_string "s" options.Size
    :: parameter_string "d" options.Default
    :: (case options.ForceDefault of
            False => ""
          | True => "f=y")
    :: parameter_string "r" options.Rating
    :: []

  fun to_query_string (options : t) : string =
    case (separate_with "&" (query_string_elements options)) of
        "" => ""
      | query_string =>
        (* Hey, we got some.  Stick a "?" at the beginning so it can be used
        as a query string. *)
        strcat "?" query_string
  end

fun calculate_hash email =
  show (Hash.md5 (textBlob (String.mp tolower (String.trim email))))

fun url' options email =
  bless
    (strcat "https://secure.gravatar.com/avatar/"
       (strcat (calculate_hash email)
          (Options.to_query_string options)))

fun url email =
  url' {Size = None, Default = None, ForceDefault = False, Rating = None} email
