defmodule Healthlocker.Caseload.UserControllerTest do
  use Healthlocker.ConnCase

  alias Healthlocker.{User, ReadOnlyRepo, EPJSClinician, EPJSUser, EPJSPatientAddressDetails}

  describe "clinician current_user is assigned" do
    setup do
      %User{
        id: 123_456,
        first_name: "My",
        last_name: "Name",,
        email: "abc@gmail.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        security_question: "Question?",
        security_answer: "Answer",
        slam_id: 201
      } |> Repo.insert

      %User{
        id: 123_457,
        first_name: "Robert",
        last_name: "MacMurray",
        email: "robert_macmurray@nhs.co.uk",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        security_question: "Question?",
        security_answer: "Answer",
        role: "clinician"
      } |> Repo.insert

      %EPJSClinician{
        GP_Code: "NyNsn50mPQPFZYn7",
        First_Name: "Robert",
        Last_Name: "MacMurray"
      } |> ReadOnlyRepo.insert

      %EPJSUser{
        Patient_ID: 201,
        Surname: "Hernandez",
        Forename: "Angela",
        Title: "Ms.",
        Patient_Name: "Angela Hernandez",
        Trust_ID: "fYXSryfK7N",
        NHS_Number: "LbweJ2oXsNl14ayv37d7",
        DOB: DateTime.from_naive!(~N[1988-05-24 00:00:00.00], "Etc/UTC"),
      } |> ReadOnlyRepo.insert

      %EPJSPatientAddressDetails{
        Patient_ID: 201,
        Address_ID: 1,
        Address1: "123 High Street",
        Address2: "London",
        Address3: "UK",
        Post_Code: "E1 8UW",
        Tel_home: "02085 123 456"
      } |> ReadOnlyRepo.insert

      {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 123_457)) }
    end

    test "GET /caseload/users/:id?section=details for details", %{conn: conn} do
      user = Repo.get(User, 123_456)
      conn = get conn, caseload_user_path(conn, :show, user, section: "details")
      assert html_response(conn, 200) =~ "Date of Birth"
    end

    test "GET /caseload/users/:id?section=interactions for interactions", %{conn: conn} do
      user = Repo.get(User, 123_456)
      conn = get conn, caseload_user_path(conn, :show, user, section: "interactions")
      assert html_response(conn, 200) =~ "Coping Strategies"
    end
  end
end