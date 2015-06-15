(* Copyright 2015 the Massachusetts Institute of Technology

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License. *)

(* Given an e-mail address, converts it to a Gravatar URL.  The URL points to an
80px by 80px image containing the avatar associated with the e-mail address, or
the blue Gravatar logo if no such avatar exists.  The result URL is an HTTPS
URL, so it won't cause any issues with use on a page served via HTTPS.

This is a specialized form of [url']. *)
val url : string -> url

structure Options : sig
  (* How Gravatar will respond if the avatar does not exist. *)
  datatype missing_image_response =
      FourOhFour  (* by returning a 404 Not Found *)
    | MysteryMan  (* by returning a silhouetted outline of a person *)
    | Identicon  (* by producing a geometric pattern *)
    | Monster  (* by generating a MS-Paint-esque monster *)
    | Wavatar  (* by generating a MS-Paint-esque face *)
    | Retro  (* by generating an 8-bit arcade-style 'alien' (think Galaga) *)
    | Blank  (* by returning a transparent PNG *)
    | Url of url  (* by returning the specified URL *)

  (* How mature your audience is.  Gravatar will censor images rated more
  maturely than you specify. *)
  datatype rating = G | PG | R | X

  (* Option struct to pass to [url'].  If a field is [None], Gravatar's API
  specifies the default, which may change as Gravatar's API updates. *)
  type t = {
      (* The size of the image, in pixels.  Images are square, so you need
      specify only one dimension. *)
      Size : option int,

      (* How Gravatar will respond if the avatar does not exist.  [None] here
      indicates an option unavailable in the [missing_image_response] type,
      namely the Gravatar logo. *)
      Default : option missing_image_response,

      (* If for some reason you want Gravatar to pretend the avatar does not
      exist, you can set this to [True]. *)
      ForceDefault : bool,

      (* How mature your audience is. *)
      Rating : option rating
    }
end

(* Like [url], but allows you to specify options. *)
val url' : Options.t -> string -> url
