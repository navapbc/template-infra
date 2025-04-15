resource "aws_pinpoint_sms_channel" "app" {
  application_id = aws_pinpoint_app.app.application_id
}
