# This is to be used when files are uploaded asynchronously from the ingest form - on upload,
# we'll store the file upload info in the DB and send the IFU's id to the ingest form so that
# on submit the controller can tie the pieces together.
#
# Longer term, this system's implementation will mean a cheap, fully async file ingest, allowing
# a huge file to be sent to Fedora after the form has returned to the user.  This could be very
# handy if we want derivative processes to happen before we stuff files into Fedora.  (Currently we
# send the file to Fedora, then the derivative process pulls the content out, stores it locally,
# and works on the local files.  This is slow and adds unnecessary network and file IO)
class IngestFileUpload < ActiveRecord::Base
  mount_uploader :file, IngestUploader
end
