class JobsController < ApplicationController
  require 'open-uri'
  require 'nokogiri'

  def scrape
    @jobs = scrape_jobs(params[:keyword], params[:page_no])
    @keyword = params[:keyword]
    @page_no = params[:page_no].to_i
  end

  def index
    @jobs = Job.all
  end

  def show
    @job = Job.find(params[:id])
  end

  def create
    @job = Job.new(job_params)
    if @job.save
      render 'scrape', notice: "Job was successfully created"
    else
      render 'scrape', notice: "Job was not successfully created"
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def update
    @job = Job.find(params[:id])
    if @job.update(job_params)
      redirect_to @job
    else
      render 'edit'
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to jobs_path
  end

  private

  def scrape_jobs (keyword, page_no)
    html = URI.open("https://www.charityjob.co.uk/jobs?keywords=#{keyword}&location=london&radius=20&contracttype=full-time&minsalary=32000&days=7&employerType=direct-employer&page=#{page_no}").read
    doc = Nokogiri::HTML(html, nil, 'utf-8')
    results = []
    doc.search('.hidden-md').each do |element|
      title = element.text.strip
      details_url = element.attribute('href').value
      url = "https://www.charityjob.co.uk#{details_url}"
      details_doc = Nokogiri::HTML(URI.open("https://www.charityjob.co.uk#{details_url}").read, nil, 'utf-8')
      charity = details_doc.search('.organisation').first.text.strip
      salary = details_doc.search('.job-summary-item:contains("£")').first.text.strip
      salary_numbers = salary.gsub(/[^0-9]/, '')
      if salary_numbers.length <= 5
        min_salary = nil
        max_salary = salary_numbers.to_i
      else
        min_salary = salary_numbers[0..4].to_i
        max_salary = salary_numbers[5..].to_i
      end
      closes_search = details_doc.search('.job-post-summary')
      closes = closes_search.search('span')[3].text.strip
      job = Job.new(
        title: title,
        url: url,
        charity: charity,
        max_salary: max_salary,
        min_salary: min_salary,
        closes: closes
      )
      results << job
    end
    results
  end

  def job_params
    params.require(:job).permit(:title, :description, :charity, :location, :url)
  end
end
