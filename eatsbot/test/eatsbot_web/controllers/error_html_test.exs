defmodule EatsbotWeb.ErrorHTMLTest do
  use EatsbotWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(EatsbotWeb.ErrorHTML, "404", "html", []) == "Not Found"
  end

  test "renders custom error pages" do
    assert render_to_string(EatsbotWeb.ErrorHTML, "404", "html",
             reason: %EatsbotWeb.NotFoundError{message: "error message"}
           ) == "error message"
  end

  test "renders 500.html" do
    assert render_to_string(EatsbotWeb.ErrorHTML, "500", "html", []) == "Internal Server Error"
  end
end
