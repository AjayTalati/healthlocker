defmodule Healthlocker.CaseloadController do
  use Healthlocker.Web, :controller

  alias Healthlocker.{EPJSTeamMember, EPJSUser, User}

  def index(conn, _params) do
    clinician = conn.assigns.current_user
    patient_ids = ConCache.get_or_store(:hl_cache, :patient_ids, fn () ->
      EPJSTeamMember
                  |> EPJSTeamMember.patient_ids(clinician."Email")
                  |> ReadOnlyRepo.all
      end)

    hl_users = patient_ids
              |> Enum.map(fn id ->
                Repo.all(from u in User,
                where: u.slam_id == ^id,
                preload: [carers: :rooms],
                preload: [:rooms])
              end)
              |> Enum.concat


    non_hl = ConCache.get_or_store(:hl_cache, :non_hl, fn () ->
      patient_ids
      |> Enum.map(fn id ->
        ReadOnlyRepo.all(from e in EPJSUser,
        where: e."Patient_ID" == ^id)
      end)
      |> Enum.concat
      |> Enum.reject(fn user ->
        Enum.any?(hl_users, fn hl ->
          user."Patient_ID" == hl.slam_id
        end)
      end)
    end)

    render(conn, "index.html", hl_users: hl_users, non_hl: non_hl)
  end
end
