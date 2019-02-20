# Page class for agency interpreter invoices report show page

require './spec/agency/helpers/agency_helper'
Dir['./spec/helpers/*.rb'].each { |file| require file }

class AgencyReportsTerpInvoices
  include Capybara::DSL
  include RSpec::Matchers
  include AgencyHelper

  def self.page
    new
  end

  ## Action Methods

  ## Validation Methods

  def validate
    expect(page).to have_selector('h1', text: 'Interpreter Invoices')
    expect(page).to have_content "Select the report period you'd like to run for this report and click \"Run\"."
    validate_reports_footer
  end

  def validate_invoice(terp:, conn:, job:)
    # The validation occurs in a loop. The counter corresponds to the default column of the report
    # (order matters). Inside the loop, we assign the invoice info to a temp string
    # The temp string and the counter (i) in the loop below is added to the "cell" xpath below.
    # The validation performs the following check:
    # 1. The invoice info "string" exists in the web report
    # 2. The invoice info "string" appears under the correct column
    # 3. The invoice info "string" is in the same row as the other related terp info

    report_div_class = 'tse-scroll-content ember-view'
    row = "//div[.='#{terp[:lastname]}']/ancestor::td/following-sibling::td"\
          "/div[.='#{terp[:firstname]}']/ancestor::td/following-sibling::td"\
          "/div[.='#{terp[:email]}']/ancestor::td/following-sibling::td"\
          "/div[.='#{job.id}']"

    # Load the contents of the report hidden because of infinite scroll
    scroll_down_until_match(xpath_data: row, scrollable_div: report_div_class)

    (3..34).each do |i|
      string = if i == 3 # Interpreter Email Column
                 terp[:email]
               elsif i == 4 # Connection Type Column
                 'staff' if conn[:type].casecmp('staff').zero?
                 'contractor' if conn[:type].casecmp('contract').zero?
               elsif i == 5 # Invoice ID
                 'any'
               elsif i == 6 # Invoice date
                 convert_date(Time.now, option: 7)
               elsif i == 7 # Job Created at
                 convert_date(Time.now, option: 7)
               elsif i == 8 # Job Assignment Status
                 job.status.downcase
               elsif i == 9 # Date Completed
                 convert_date(Time.now, option: 7)
               elsif i == 10 # Timezone
                 job.timezone
               elsif i == 11 # Schedule Starts At
                 convert_date(job.start_time, option: 8)
               elsif i == 12 # Schedule Ends At
                 convert_date(job.end_time, option: 8)
               elsif i == 13 # Actual Starts At
                 convert_date(job.actual_start_time, option: 8)
               elsif i == 14 # Actual Ends At
                 convert_date(job.actual_end_time, option: 8)
               elsif i == 15 # Admin Time Minutes
                 job.admin_time.nil? ? '0' : convert_admin_time_to_min(job.admin_time)
               elsif i == 16 # Admin Time Category
                 job.admin_time.nil? ? 'unspecified' : job.admin_time_type
               elsif i == 17 # Actual Mileage
                 if job.type.casecmp('onsite').zero?
                   job.miles.nil? ? '0' : job.miles
                 end
               elsif i == 18 # Business ID
                 'any'
               elsif i == 19 # Business Name
                 job.business
               elsif i == 20 # Business Code
                 'any'
               elsif i == 21 # Job External Reference
                 job.reference_code
               elsif i == 22 # Consumer TODO: Add MPOC validation
                 'any'
               elsif i == 23 # Job ID
                 job.id
               elsif i == 24 # Job Type
                 job.type.casecmp('onsite').zero? ? 'on_site' : 'remote'
               elsif i == 25 # Miles
                 job.miles
               elsif i == 26 # Title
                 job.title
               elsif i == 27 # Description
                 job.public_description
               elsif i == 28 # Billing Notes
                 job.bill_notes
               elsif i == 29 # Job Date
                 convert_date(job.date, option: 7)
               # TODO: Figure out how to perform validation for interpreter costs
               # The invoice helper class is for VFB invoices. Might need one for interpreter
               elsif i == 30 # Rate Starts At
                 'any'
               elsif i == 31 # Rate Ends At
                 'any'
               elsif i == 32 # Payment Source Reason
                 'any'
               elsif i == 33 # Job Assignment ID
                 'any'
               elsif i == 34 # Line Item ID
                 'any'
               elsif i == 35 # Rate
                 'any'
               elsif i == 36 # Units
                 'any'
               elsif i == 37 # Rate Type
                 'any'
               elsif i == 38 # Subtotal
                 # Note: This is not the taxable subtotal in the invoice
                 # This is the line item sub total
                 'any'
               elsif i == 39 # Interpreter Mileage Costs
                 job.terp_mile_total
               elsif i == 40 # Total Interpreter Costs
                 job.terp_total
               end

      div = if string.nil?
              '' # The string is empty. Check that the cell exists)
            elsif string.casecmp('any').zero?
              '/div/text()/ancestor::td' # Verify that the cell is not empty
            else
              # Terp invoice info validation. Only doing partial match
              "/div[contains(.,'#{string}')]"
            end

      cell = "//div[.='#{terp[:lastname]}']/ancestor::td/following-sibling::td"\
             "/div[.='#{terp[:firstname]}']/ancestor::td/following-sibling::td"\
             "/div[.='#{terp[:email]}']/ancestor::tr//td[#{i}]#{div}"

      expect(page).to have_selector(:xpath, cell)
    end
  end

  def validate_default_columns
    expect(page).to have_selector(:xpath, "//th[contains(.,'Last Name')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'First Name')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Email')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Interpreter Type')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Invoice Id')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Invoice Date')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Created At')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Job Assignment Status')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Date Completed')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Timezone')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Scheduled Starts At')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Scheduled Ends At')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Job Assignment Actual Starts At')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Job Assignment Actual Ends At')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Admin Time Minutes')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Admin Time Category')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Actual Mileage')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Business Id')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Business Name')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Business Code')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'External Reference')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Consumer')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Job Id')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Job Type')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Miles')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Title')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Description')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Billing Notes')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Job Date')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Rate Starts At')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Rate Ends At')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Payment Source Reason')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Job Assignment Id')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Line Item Id')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Rate')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Units')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Rate Type')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Subtotal')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Interpreter Mileage Costs')]")
    expect(page).to have_selector(:xpath, "//th[contains(.,'Total Interpreter Costs')]")
  end

  def validate_terp_invoices_report_csv
    click_export_to_csv

    report = downloaded_csv_to_hash
    invoice = report.sample

    # Validate one random row in the csv file
    expect(invoice[:first_name]).to be_instance_of String
    expect(invoice[:last_name]).to be_instance_of String
    expect(invoice[:email]).to be_instance_of String
    expect(invoice[:job_id]).to be_instance_of String
    expect(invoice[:total_interpreter_costs]).to be_instance_of String
  end
end
