require "spec_helper"

feature "user updates grocery item" do
  scenario "successfully updates grocery item" do
    visit "/groceries"
    fill_in "Name", with: "Peanut Butter"
    click_button "Submit"
    click_link "Update"
    fill_in "New Name", with: "Almond Butter"
    click_button "Update"

    expect(page).to have_content "Almond Butter"
  end


end
