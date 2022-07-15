# Common tags for all accounts and environments
output "default_tags" {
    value = {
        project     = "template-application-nextjs"
        owner       = "platform"
        repository  = "https://github.com/navapbc/template-application-nextjs"
        terraform   = true
        # description is set in each environments local use key project_description if required.        
    }
}