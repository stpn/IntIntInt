module ApplicationHelper
  def bootstrap_form_for(name, *args, &block)
    options = args.extract_options!
    form_for(name, *(args << options.merge(:builder => BootstrapFormBuilder)), &block)
  end
end