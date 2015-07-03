class Request < ActiveRecord::Base
  require 'builder'
  belongs_to :query
  
  def self.data(method, params)
    case method
    when '/checkapplication/single'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
	application_info(root, params) if params[:application_id]
      end
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
    when '/validate' || '/import'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
        data.PackageData do |pd|
          campaign_info(pd, params) if params[:campaign_info]
	  admission_info(pd, params) if params[:admission_info]
          institution_achievements(pd, params) if params[:institution_achievements]
	  applications(pd, params) if params[:applications]
          recommended_lists(pd, params) if params[:recommended_lists]
          orders_of_admission(pd, params) if params[:orders_of_admission]
        end
      end
    when '/import'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
        data.PackageData do |pd|
          campaign_info(pd, params) if params[:campaign_info]
	  admission_info(pd, params) if params[:admission_info]
          institution_achievements(pd, params) if params[:institution_achievements]
	  applications(pd, params) if params[:applications]
          recommended_lists(pd, params) if params[:recommended_lists]
          orders_of_admission(pd, params) if params[:orders_of_admission]
        end
      end
    when '/delete'
      data = ::Builder::XmlMarkup.new(indent: 2)
      data.Root do |root|
        auth_data(root)
        data.DataForDelete do |pd|
	  applications_del(pd, params) if params[:applications]
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
    c = Campaign.find_by_id(params[:request][:campaign_id])
    root.CampaignInfo do |ci|
      ci.Campaigns do |ca|
        ca.Campaign do |cm|
          cm.UID c.id
          cm.Name c.name
          cm.YearStart c.year_start
          cm.YearEnd c.year_end
          c.campaign_dates.map{|d| {education_form_id: d.education_form_id}}.uniq.each do |efm|
            cm.EducationForms do |ef|
              ef.EducationFormID efm[:education_form_id]
            end
          end
          cm.StatusID c.status_id
          cm.EducationLevels do |els|
            c.campaign_dates.map{|d| {course: d.course, education_level_id: d.education_level_id}}.uniq.each do |elm|
              els.EducationLevel do |el|
                el.Course elm[:course]
                el.EducationLevelID elm[:education_level_id]
              end
            end
          end
          cm.CampaignDates do |cds|
            c.campaign_dates.each do |cdm|
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

  def self.institution_achievements(root, params)
    institution_achievements = ::Builder::XmlMarkup.new(indent: 2)
    c = InstitutionAchievement.where(campaign_id: params[:request][:campaign_id])
    root.InstitutionAchievements do |ias|
      c.each do |cm|
        ias.InstitutionAchievement do |ia|
          ia.IAUID cm.id
          ia.Name cm.name
          ia.IdCategory cm.id_category
          ia.MaxValue cm.max_value
          ia.CampaignUID cm.campaign_id
        end
      end
    end
  end
  
  def self.admission_info(root, params)
    admission_info = ::Builder::XmlMarkup.new(indent: 2)
    c = Campaign.find_by_id(params[:request][:campaign_id])
    root.AdmissionInfo do |ai|
      ai.AdmissionVolume do |av|
	c.competitive_group_items.each do |cgi|
	  av.Item do |i|
	    i.UID cgi.id
	    i.CampaignUID c.id
	    i.EducationLevelID cgi.education_level_id
	    i.Course cgi.competitive_group.course
	    i.DirectionID cgi.direction_id
	    i.NumberBudgetO cgi.number_budget_o if cgi.number_budget_o
	    i.NumberBudgetOZ cgi.number_budget_oz if cgi.number_budget_oz
	    i.NumberBudgetZ cgi.number_budget_z if cgi.number_budget_z
	    i.NumberPaidO cgi.number_paid_o if cgi.number_paid_o
	    i.NumberPaidOZ cgi.number_paid_oz if cgi.number_paid_oz
	    i.NumberPaidZ cgi.number_paid_z if cgi.number_paid_z
	    i.NumberTargetO cgi.number_target_o if cgi.number_target_o
	    i.NumberTargetOZ cgi.number_target_oz if cgi.number_target_oz
	    i.NumberTargetZ cgi.number_target_z if cgi.number_target_z
	    i.NumberQuotaO cgi.number_quota_o if cgi.number_quota_o
	    i.NumberQuotaOZ cgi.number_quota_oz if cgi.number_quota_oz
	    i.NumberQuotaZ cgi.number_quota_z if cgi.number_quota_z	    
	  end
	end
      end
      ai.DistributedAdmissionVolume do |da|
        c.competitive_group_items.each do |cgi|
          da.Item do |i|
            i.AdmissionVolumeUID cgi.id
            i.LevelBudget 1
	    i.NumberBudgetO cgi.number_budget_o if cgi.number_budget_o
	    i.NumberBudgetOZ cgi.number_budget_oz if cgi.number_budget_oz
	    i.NumberBudgetZ cgi.number_budget_z if cgi.number_budget_z
	    i.NumberTargetO cgi.number_target_o if cgi.number_target_o
	    i.NumberTargetOZ cgi.number_target_oz if cgi.number_target_oz
	    i.NumberTargetZ cgi.number_target_z if cgi.number_target_z
	    i.NumberQuotaO cgi.number_quota_o if cgi.number_quota_o
	    i.NumberQuotaOZ cgi.number_quota_oz if cgi.number_quota_oz
	    i.NumberQuotaZ cgi.number_quota_z if cgi.number_quota_z
          end
        end
      end
      ai.CompetitiveGroups do |cgs|
	c = CompetitiveGroup.where(campaign_id: params[:request][:campaign_id]) 
	c.each do |cm|
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
		  cm.competitive_group_target_items.group_by{|i| i.target_organization.target_organization_name}.sort.each do |ton, cgtis|
		    tos.TargetOrganization do |to|
		      to.UID TargetOrganization.find_by_target_organization_name(ton).id
		      to.TargetOrganizationName ton
		      to.Items do |i|
			cgtis.each do |cgtim|  
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
                    eti.EntranceTestSubject do |es|
                      es.SubjectID etim.subject_id
                    end
		  end
		end
		end
	  end
	end
      end
    end
  end
  
  def self.applications(root, params)
    applications = ::Builder::XmlMarkup.new(indent: 2)
    applications = Application.where(campaign_id: params[:request][:campaign_id], status_id: [4, 6])
    root.Applications do |as|
      applications.each do |am|
        as.Application do |a|
          a.UID am.id
          a.ApplicationNumber [am.campaign.year_start, "%04d" % am.application_number].join('-')
          a.Entrant do |e|
            e.UID am.id
            e.FirstName am.entrant_first_name
            e.MiddleName am.entrant_middle_name
            e.LastName am.entrant_last_name
            e.GenderID am.gender_id
          end
          a.RegistrationDate am.registration_date.to_datetime
          a.LastDenyDate am.last_deny_day.to_datetime if am.last_deny_day
          a.NeedHostel am.need_hostel
          a.StatusID am.status_id
          a.SelectedCompetitiveGroups do |scg|
            case am.campaign.year_end
            when 2013
              scg.CompetitiveGroupID 1 if am.lech_budget || am.lech_paid
              scg.CompetitiveGroupID 2 if am.ped_budget || am.ped_paid
              scg.CompetitiveGroupID 3 if am.stomat_budget || am.stomat_paid
            when 2014
              scg.CompetitiveGroupID 4
            when 2015
              scg.CompetitiveGroupID am.competitive_groups.first.id
            end
          end
          a.SelectedCompetitiveGroupItems do |scgi|
            case am.campaign.year_end
            when 2013
              scgi.CompetitiveGroupItemID 1 if am.lech_budget || am.lech_paid
              scgi.CompetitiveGroupItemID 2 if am.ped_budget || am.ped_paid
              scgi.CompetitiveGroupItemID 3 if am.stomat_budget || am.stomat_paid
            when 2014
              scgi.CompetitiveGroupItemID 4 unless am.competitions.where(competition_item_id: [1, 4, 7, 10, 13, 16]).empty?
              scgi.CompetitiveGroupItemID 5 unless am.competitions.where(competition_item_id: [2, 5, 8, 11, 14, 17]).empty?
              scgi.CompetitiveGroupItemID 6 unless am.competitions.where(competition_item_id: [3, 6, 9, 12, 15, 18]).empty?
            when 2015
              scgi.CompetitiveGroupItemID 7 unless am.competitions.joins(:competition_item).where(competition_items: {code: [1, 4, 7, 10, 13, 16]}).empty?
              scgi.CompetitiveGroupItemID 8 unless am.competitions.joins(:competition_item).where(competition_items: {code: [2, 5, 8, 11, 14, 17]}).empty?
              scgi.CompetitiveGroupItemID 9 unless am.competitions.joins(:competition_item).where(competition_items: {code: [3, 6, 9, 12, 15, 18]}).empty?
            end
          end
          a.FinSourceAndEduForms do |fsaef|
            case am.campaign.year_end
            when 2013
              if am.lech_budget || am.ped_budget || am.stomat_budget
                fsaef.FinSourceEduForm do |fsef|
                  fsef.FinanceSourceID 14
                  fsef.EducationFormID 11
                end
              end
              if am.lech_paid || am.ped_paid || am.stomat_paid
                fsaef.FinSourceEduForm do |fsef|
                  fsef.FinanceSourceID 15
                  fsef.EducationFormID 11
                end
              end
              if am.target_organization_id
                fsaef.FinSourceEduForm do |fsef|
                  fsef.FinanceSourceID 16
                  fsef.EducationFormID 11
                  fsef.TargetOrganizationUID am.target_organization_id
                end
              end
            else
              am.competitions.each do |competition|
                fsaef.FinSourceEduForm do |fsef|
                  fsef.FinanceSourceID competition.competition_item.finance_source_id if competition.competition_item.finance_source_id
                  fsef.EducationFormID 11
                  fsef.CompetitiveGroupID competition.competitive_group.id
                  fsef.CompetitiveGroupItemID competition.competition_item.competitive_group_item_id if competition.competition_item.competitive_group_item_id
                  fsef.Priority competition.priority
                  fsef.TargetOrganizationUID am.target_organization_id if am.target_organization_id
                end
              end
            end
          end
          a.EntranceTestResults do |etrs|
            am.marks.each do |mark|
              etrs.EntranceTestResult do |etr|
                etr.UID mark.id
                etr.ResultValue mark.value
                etr.ResultSourceTypeID 1
                  etr.EntranceTestSubject do |ets|
                    ets.SubjectID mark.entrance_test_item.subject_id
                  end
                etr.EntranceTestTypeID mark.entrance_test_item.entrance_test_type_id
                etr.CompetitiveGroupID mark.entrance_test_item.competitive_group_id
              end
            end
          end
          a.ApplicationDocuments do |ad|
            im = am.identity_document
            ad.IdentityDocument do |id|
              id.OriginalReceived true
              id.DocumentSeries im.identity_document_series if im.identity_document_series
              id.DocumentNumber im.identity_document_number
              id.DocumentDate im.identity_document_date
              id.IdentityDocumentTypeID im.identity_document_type_id
              id.NationalityTypeID am.nationality_type_id
              id.BirthDate am.birth_date
            end
            ad.EduDocuments do |eds|
              em = am.education_document
              eds.EduDocument do |ed|
                case em.education_document_type_id
                when 1
                  ed.SchoolCertificateDocument do |scd|
                    scd.OriginalReceived am.original_received_date ? true : false
                    scd.OriginalReceivedDate am.original_received_date if am.original_received_date
                    scd.DocumentSeries em.education_document_series.to_s
                    scd.DocumentNumber em.education_document_number.to_s
                  end
                when 5
                  ed.MiddleEduDiplomaDocument do |medd|
                    medd.OriginalReceived am.original_received_date ? true : false
                    medd.OriginalReceivedDate am.original_received_date if am.original_received_date
                    medd.DocumentSeries em.education_document_series.to_s
                    medd.DocumentNumber em.education_document_number.to_s
                  end
                when 4
                  ed.HighEduDiplomaDocument do |hedd|
                    medd.OriginalReceived am.original_received_date ? true : false
                    medd.OriginalReceivedDate am.original_received_date if am.original_received_date
                    medd.DocumentSeries em.education_document_series.to_s
                    medd.DocumentNumber em.education_document_number.to_s
                  end
                end
              end
            end
          end
          unless am.institution_achievements.empty?
            a.IndividualAchievements do |ias|
              am.institution_achievements.each do |iam|
                ias.IndividualAchievement do |ia|
                  ia.IAUID iam.id
                  ia.IAName iam.name
                  ia.IAMark iam.max_value
                  ia.IADocumentUID am.education_document.id
                end
              end
            end
          end
        end
      end
    end
  end
  
  def self.recommended_lists(root, params)
    recommended_lists = ::Builder::XmlMarkup.new(indent: 2)
    order_dates = {}
    CampaignDate.where(campaign_id: params[:request][:campaign_id]).where.not(stage: nil).each{|d| order_dates[d.date_order] = d.stage}
    root.RecommendedLists do |rls|
      order_dates.each do |date, stage|
        as = Application.joins(:competitions).where(campaign_id: params[:request][:campaign_id], competitions: {recommended_date: date}).uniq
        unless as.empty?
          as.each do |a|
            rls.RecommendedList do |rl|
              rl.Stage stage
              rl.RecLists do |recls|
                recls.RecList do |recl|
                  recl.Application do |am|
                    am.ApplicationNumber [a.campaign.year_start, "%04d" % a.application_number].join('-')
                    am.RegistrationDate a.registration_date.to_datetime
                  end
                  recl.FinSourceAndEduForms do |fsaefs|
                    cs = a.competitions.where(recommended_date: date)
                    cs.each do |c|
                      fsaefs.FinSourceEduForm do |fsaef|
                        fsaef.EducationalLevelID 5
                        fsaef.EducationFormID 11
                        fsaef.CompetitiveGroupID c.competition_item.competitive_group_item.competitive_group_id
                        fsaef.DirectionID c.competition_item.competitive_group_item.direction_id
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
  
  def self.orders_of_admission(root, params)
    orders_of_admission = ::Builder::XmlMarkup.new(indent: 2)
    order_dates = {}
    CampaignDate.where(campaign_id: params[:request][:campaign_id]).where.not(stage: nil).each{|d| order_dates[d.date_order] = d.stage}
    as = Application.joins(:competitions).where(campaign_id: params[:request][:campaign_id]).where.not(competitions: {admission_date: nil}).uniq
    root.OrdersOfAdmission do |ooas|
      as.each do |a|
        ooas.OrderOfAdmission do |ooa|
          ooa.Application do |am|
            am.ApplicationNumber [a.campaign.year_start, "%04d" % a.application_number].join('-')
            am.RegistrationDate a.registration_date.to_datetime
          end
          c = a.competitions.order(:admission_date).where.not(admission_date: nil).last
          ooa.DirectionID c.competition_item.competitive_group_item.direction_id
          ooa.EducationFormID 11
          ooa.FinanceSourceID c.competition_item.finance_source_id
          ooa.EducationLevelID 5
          ooa.Stage order_dates[c.admission_date] if order_dates[c.admission_date]
          ooa.IsBeneficiary (10..12).to_a.include?(c.competition_item_id) ? true : false 
        end
      end
    end
  end
  
  def self.applications_del(root, params)
    applications_del = ::Builder::XmlMarkup.new(indent: 2)
    @a = Application.where(campaign_id: params[:request][:campaign_id])
    root.Applications do |as|
      @a.each do |am|
	as.Application do |a|
	  a.ApplicationNumber [am.campaign.year_start, "%04d" % am.application_number].join('-')
	  a.RegistrationDate am.registration_date.to_datetime
	end
	as.Application do |a|
	  a.ApplicationNumber [am.campaign.year_start, "%04d" % am.application_number].join('-')
	  a.RegistrationDate am.registration_date.to_datetime.to_s.gsub('+00:00', '')
	end
      end
    end
  end
  
  def self.application_info(root, params)
    a = Application.find(params[:application_id])
    root.CheckApp do |ca|
      ca.ApplicationNumber [a.campaign.year_start, "%04d" % a.application_number].join('-')
      ca.RegistrationDate a.registration_date.to_datetime.to_s
    end
  end
end
