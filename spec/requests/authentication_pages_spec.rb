require 'spec_helper'

describe "AuthenticationPages" do
  
  subject { page }
  
  describe "sign in page" do
    
    before { visit signin_path }
    
    it { should have_title(full_title("Sign in")) }
    it { should have_selector("h2", text: "Sign in") }
    
  end
  
  describe "signing in" do
    
    before { visit signin_path }
    let(:sign_in) { "Sign in" }
    
    describe "with invalid info" do
      
      before { click_button sign_in }
      
      it { should have_title("Sign in") }
      it { should have_selector("div.alert.alert-danger") }
      
      describe "after visiting another page" do
        
        before { click_link "Home" }
        
        it { should_not have_selector("div.alert.alert-danger") }
        
      end
      
    end
    
    describe "with valid info" do
      
      let(:user) { FactoryGirl.create(:user) }
      
      before do
        signin user
      end
      
      it { should have_title user.first_name }
      it { should have_link "Profile", href: user_path(user) }
      it { should have_link "Sign out", href: signout_path }
      it { should_not have_link "Sign in", href: signin_path }
      
      describe "followed by signing out" do
        
        before { click_link "Sign out" }
        
        it { should have_link("Sign in") }
        
      end
      
    end
    
  end
  
  describe "authorization" do
    
    describe "for non-signed in users" do
      
      let(:user) { FactoryGirl.create(:user) }
      
      describe "in the users controller" do
        
        describe "visiting the edit page" do
          
          before { visit edit_user_path(user) }
          
          it { should have_title "Sign in" }
          
        end
        
        describe "submitting to the update action" do
          
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
          
        end
        
      end
      
    end
    
    describe "as wrong user" do
      
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@email.com") }
      
      before { signin user, no_capybara: true }
      
      describe "submitting a GET request to the User#edit action" do
        
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title("Edit user")) }
        specify { expect(response).to redirect_to root_url }
        
      end
      
    end
    
    describe "for non-signed-in users" do
      
      let(:user) { FactoryGirl.create(:user) }
      
      describe "when attempting to visit a protected page" do
        
        before do
          
          visit edit_user_path(user)
          fill_in "session_email", with: user.email
          fill_in "session_password", with: user.password
          click_button "Sign in"
          
        end
        
        describe "after signing in" do
          
          it "should render the desired protected page" do
            expect(page).to have_title("Edit user")
          end
          
        end
        
        
      end
      
      describe "in the users controller" do
          
        describe "visiting the user index" do
          
          before { visit users_path }
          
          it { should have_title(full_title("Sign in")) }
          
        end
        
      end
      
    end
    
    describe "as a non-admin user" do
      
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      
      before { signin non_admin, no_capybara: true }
      
      describe "submittind a DELETE request to the Users#destroy action" do
        
        before { delete users_path(user) }
        specify { expect(response).to redirect_to(root_url) }
        
      end
      
    end
    
  end
  
end
