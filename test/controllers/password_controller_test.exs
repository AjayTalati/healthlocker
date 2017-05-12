defmodule Healthlocker.PasswordControllerTest do
  use Healthlocker.ConnCase

  alias Healthlocker.User

  @existing_email %{
    email: "email@example.com"
  }

  @non_existent_email %{
    email: "nope@email.com"
  }

  @invalid_attrs %{}

  setup do
    %User{
      id: 123456,
      first_name: "My",
      last_name: "Name",
      email: "email@example.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
      security_question: "Question?",
      security_answer: "Answer",
      slam_id: 1
    } |> Repo.insert

    :ok
  end

  test "GET /password/new", %{conn: conn} do
    conn = get conn, password_path(conn, :new)
    assert html_response(conn, 200) =~ "Password reset"
  end

  test "POST /password with existing email", %{conn: conn} do
    conn = post conn, password_path(conn, :create), user: @existing_email
    assert redirected_to(conn) == login_path(conn, :index)
    assert get_flash(conn, :info) == "Password reset sent"
  end

  test "POST /password with non_existent_email", %{conn: conn} do
    conn = post conn, password_path(conn, :create), user: @non_existent_email
    assert redirected_to(conn) == login_path(conn, :index)
    assert get_flash(conn, :error) == "Could not send reset email. Please try again later"
  end

  test "POST /password with invalid data", %{conn: conn} do
    conn = post conn, password_path(conn, :create), user: @invalid
    assert redirected_to(conn) == login_path(conn, :index)
    assert get_flash(conn, :error) == "Could not send reset email. Please try again later"
  end
end
