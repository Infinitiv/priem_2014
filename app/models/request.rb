class Request < ActiveRecord::Base
  require 'builder'
  belongs_to :query
  
  def self.data(method, params)
    case method
    when '/dictionary'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
      end
    when '/institutioninfo'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
      end
    when '/validate'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
        data.PackageData do |pd|
          campaign_info(pd, params) if params[:campaign_info]
	  admission_info(pd, params) if params[:admission_info]
	  applications(pd, params) if params[:applications]
        end
      end
    end
  end
  
  def self.auth_data(root)
    auth_data = ::Builder::XmlMarkup.new(indent: 2)
    a = AuthData.first
    root.AuthData do |ad|
      ad.Login a.login
      ad.Pass a.pass
    end
  end
  
  def self.campaign_info(root, params)
    campaign_info = ::Builder::XmlMarkup.new(indent: 2)
    @c = Campaign.where(id: params[:campaign_id])
    root.CampaignInfo do |ci|
      ci.Campaigns do |ca|
        @c.each do |cm|
          ca.Campaign do |c|
            c.UID cm.id
            c.Name cm.name
            c.YearStart cm.year_start
            c.YearEnd cm.year_end
            cm.education_forms.each do |efm|
              c.EducationForms do |ef|
                ef.EducationFormID efm.education_form_id
              end
            end
            c.StatusID cm.status_id
            c.EducationLevels do |els|
              cm.education_levels.each do |elm|
                els.EducationLevel do |el|
                  el.Course elm.course
                  el.EducationLevelID elm.education_level_id
                end
              end
            end
            c.CampaignDates do |cds|
              cm.campaign_dates.each do |cdm|
                cds.CampaignDate do |cd|
                  cd.UID cdm.id
                  cd.Course cdm.course
                  cd.EducationLevelID cdm.education_level_id
                  cd.EducationFormID cdm.education_form_id
                  cd.EducationSourceID cdm.education_source_id
                  cd.Stage cdm.stage if cdm.stage
                  cd.DateStart cdm.date_start
                  cd.DateEnd cdm.date_end
                  cd.DateOrder cdm.date_order
                end
              end
            end
          end
        end
      end
    end
  end

  def self.admission_info(root, params)
    admission_info = ::Builder::XmlMarkup.new(indent: 2)
    @c = AdmissionVolume.where(campaign_id: params[:campaign_id])
    root.AdmissionInfo do |ai|
      ai.AdmissionVolume do |av|
	@c.each do |cm|
	  av.Item do |i|
	    i.UID cm.id
	    i.CampaignUID cm.campaign_id
	    i.EducationLevelID cm.education_level_id
	    i.Course cm.course
	    i.DirectionID cm.direction_id
	    i.NumberBudgetO cm.number_budget_o if cm.number_budget_o
	    i.NumberBudgetOZ cm.number_budget_oz if cm.number_budget_oz
	    i.NumberBudgetZ cm.number_budget_z if cm.number_budget_z
	    i.NumberPaidO cm.number_paid_o if cm.number_paid_o
	    i.NumberPaidOZ cm.number_paid_oz if cm.number_paid_oz
	    i.NumberPaidZ cm.number_paid_z if cm.number_paid_z
	    i.NumberTargetO cm.number_target_o if cm.number_target_o
	    i.NumberTargetOZ cm.number_target_oz if cm.number_target_oz
	    i.NumberTargetZ cm.number_target_z if cm.number_target_z
	    i.NumberQuotaO cm.number_quota_o if cm.number_quota_o
	    i.NumberQuotaOZ cm.number_quota_oz if cm.number_quota_oz
	    i.NumberQuotaZ cm.number_quota_z if cm.number_quota_z	    
	  end
	end
      end
      ai.CompetitiveGroups do |cgs|
	@c = CompetitiveGroup.where(campaign_id: params[:campaign_id]) 
	@c.each do |cm|
	  cgs.CompetitiveGroup do |cg|
	    cg.UID cm.id
	    cg.CampaignUID cm.campaign_id
	    cg.Course cm.course
	    cg.Name cm.name
	    cg.Items do |i|
	      cm.competitive_group_items.each do |cgim|
		i.CompetitiveGroupItem do |cgi|
		  cgi.UID cgim.id
		  cgi.EducationLevelID cgim.education_level_id
		  cgi.DirectionID cgim.direction_id
		  cgi.NumberBudgetO cgim.number_budget_o if cgim.number_budget_o
		  cgi.NumberBudgetOZ cgim.number_budget_oz if cgim.number_budget_oz
		  cgi.NumberBudgetZ cgim.number_budget_z if cgim.number_budget_z
		  cgi.NumberPaidO cgim.number_paid_o if cgim.number_paid_o
		  cgi.NumberPaidOZ cgim.number_paid_oz if cgim.number_paid_oz
		  cgi.NumberPaidZ cgim.number_paid_z if cgim.number_paid_z
		  cgi.NumberQuotaO cgim.number_quota_o if cgim.number_quota_o
		  cgi.NumberQuotaOZ cgim.number_quota_oz if cgim.number_quota_oz
		  cgi.NumberQuotaZ cgim.number_quota_z if cgim.number_quota_z
		end
	      end
	    end
		cg.TargetOrganizations do |tos|
		  cm.target_organizations.each do |tom|
		    tos.TargetOrganization do |to|
		      to.UID tom.id
		      to.TargetOrganizationName tom.target_organization_name
		      to.Items do |i|
			tom.competitive_group_target_items.each do |cgtim|  
			  i.CompetitiveGroupTargetItem do |cgti|
			    cgti.UID cgtim.id
			    cgti.EducationLevelID cgtim.education_level_id
			    cgti.NumberTargetO cgtim.number_target_o if cgtim.number_target_o
			    cgti.NumberTargetOZ cgtim.number_target_oz if cgtim.number_target_oz
			    cgti.NumberTargetZ cgtim.number_target_z if cgtim.number_target_z
			    cgti.DirectionID cgtim.direction_id
			  end
			end
		      end
		    end
		  end
		end
		cg.EntranceTestItems do |etis|
		cm.entrance_test_items.each do |etim|
		  etis.EntranceTestItem do |eti|
		    eti.UID etim.id
		    eti.EntranceTestTypeID etim.entrance_test_type_id
		    eti.Form etim.form
		    eti.MinScore etim.min_score
		    etim.entrance_test_subjects.each do |esm|
		      eti.EntranceTestSubject do |es|
			es.SubjectID esm.subject_id
		      end
		    end
		  end
		end
		end
	  end
	end
      end
    end
  end
end
