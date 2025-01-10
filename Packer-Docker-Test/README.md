This project is to use Packer and Terraform together, to create a custom image with Packer and create a running container on that image with Terraform

Step 1: Dockerfile
-
* We start by building from a slim version of Python.
* Then we set the working directory and copy over all the contents of the current folder to the image.
* From inside the image, we are having pip install the contents of the *requirements.txt* file.
* Then we go ahead and expose the port we want the image to run from.
* Finally we create our entrypoint command and we run the app.py file, which is creating a Flask app and rendering the HTML files located in the directory.

Step 2: Packer
-
* Packer is using all the listed configurations from the ***.pkr.hcl*** file to build our image.
* Our source block tells Packer to build the image from the Dockerfile in the same directory.
* The build block names our image during the creation and adds the proper tag using the *post-processor*.
* Run the commands ***packer init .*** and ***packer validate .*** to ensure your Packer environment is set up properly.
* Run the command ***packer build web-app-test.pkr.hcl*** to create the image.
* In the Packer file, we have listed to create a new image, based on the Dockerfile in the same directory.
* The Dockerfile is set to build from a slim python image, copy all the files from the *web-app* folder, and run the app.py file on startup.

Step 3: Terraform
-
* Within our *main.tf* file, we list a data block for our local image and a resource block to create our docker container.
* The data block does need the proper tag for the image, in order to find it properly.
* Our output file will list the web address of the docker container after creation, so you can easily copy/paste or CMD-Click on it to open the address in your browser.
* Run the command ***terraform init*** to ensure the docker provider is pulled for your resouces.
* Run the command ***terraform plan*** to verify all the changes that will be made, then run the command ***terraform apply*** to make those changes.

Results
-
* You should be able to head to http://localhost:8080 and the newly created container should be up and running.