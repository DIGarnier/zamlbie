module type Serializer = sig
  type request
  type response

  val serialize_request : request -> string
  val deserialize_response : string -> response
end

module Make (S : Serializer) = struct
  type t = unit

  let request ?(timeout : float option) (url : string) (req : S.request option)
    : (S.response, Raw_client.error) result Lwt.t
    =
    let open Lwt.Infix in
    match req with
    | None ->
      (match timeout with
       | None -> Raw_client.get url
       | Some t -> Raw_client.get ~timeout:t url)
      >|= Result.map S.deserialize_response
    | Some req ->
      let serialized = S.serialize_request req in
      (match timeout with
       | None -> Raw_client.post url serialized
       | Some t -> Raw_client.post ~timeout:t url serialized)
      >|= Result.map S.deserialize_response
  ;;

  let get ?(timeout : float option) (url : string) : (S.response, Raw_client.error) result Lwt.t =
    request ?timeout url None
  ;;

  let post ?(timeout : float option) (url : string) (req : S.request)
    : (S.response, Raw_client.error) result Lwt.t
    =
    request ?timeout url (Some req)
  ;;
end
