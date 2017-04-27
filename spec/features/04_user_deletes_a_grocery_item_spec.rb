require "spec_helper"

feature "user deletes grocery item" do
  scenario "successfully delete grocery item" do
    visit "/groceries"
    fill_in "Name", with: "Peanut Butter"
    click_button "Submit"
    click_button "Delete"

    expect(page).to_not have_content "Peanut Butter"
  end



end
