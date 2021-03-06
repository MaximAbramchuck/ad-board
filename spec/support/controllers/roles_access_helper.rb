module Controllers
  module RolesAccessHelper
    def for_users(*roles, &block)
      roles.each do |role|
        context "for #{role}" do
          if role == :owner 
            let(:user) { advert.user }
          else
            let(:user) { Fabricate(:user, role: role) }
          end

          before :each do
            sign_in(user)
          end

          instance_exec(&block)
        end
      end
    end

    def it_loads_requested(resource, &request)
      if(resource==:user)
        let(:user) { Fabricate(:user) }
      end

      it "loads requested #{resource}" do
        admin = Fabricate(:user, role: admin)
        sign_in(admin)

        instance_exec(&request)

        expect(assigns(resource)).to eq(instance_eval(resource.to_s))
      end
    end

    def it_denies_access_for(*roles, &block)
      roles.each do |role|
        it "denies access for the #{role}" do
          instance_exec(&block)

          expect(response).not_to be_successful
        end
      end
    end

    def it_permits_access_for(*roles, &block)
      roles.each do |role|
        it "permits access for the #{role}" do
          instance_exec(&block)

          expect(response).to be_successful
        end
      end
    end

    alias :for_user :for_users
  end
end
