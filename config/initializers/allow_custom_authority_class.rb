# Patches QA to let us specify custom alternative modules
Rails.application.config.to_prepare do
  Qa::TermsController.send(:prepend, OregonDigital::Qa::CustomAuthorityClass)
  OregonDigital::Qa::CustomAuthorityClass.qa_class_patterns = ["OregonDigital::ControlledVocabularies::%s"]
end
