# Common tags for all accounts and environments
output "tags" {
    value = {
        project     = "template-application-nextjs"
        owner       = "platform"
        repository  = "https://github.com/navapbc/template-application-nextjs"
        terraform   = true        
    }
}