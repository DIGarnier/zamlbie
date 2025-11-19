module type Serializer = sig
  type request
  type response

  val serialize_request : request -> string
  val deserialize_response : string -> response
end

module Make (S : Serializer) = struct
  type t = unit

  let request ?timeout (url : string) (req : S.request option)
    : (S.response, Raw_client.error) result Lwt.t
    =
    let open Lwt.Infix in
    match req with
    | None -> Raw_client.get ?timeout url >|= Result.map S.deserialize_response
    | Some req ->
      let serialized = S.serialize_request req in
      Raw_client.post ?timeout url serialized >|= Result.map S.deserialize_response
  ;;

  let get ?timeout (url : string) : (S.response, Raw_client.error) result Lwt.t =
    request ?timeout url None
  ;;

  let post ?timeout (url : string) (req : S.request)
    : (S.response, Raw_client.error) result Lwt.t
    =
    request ?timeout url (Some req)
  ;;
end
