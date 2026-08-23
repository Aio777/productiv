# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* **Ruby version**
    - Rails 8.0.5

* **System dependencies**
    - **You can see the list of gems we used by running in terminal:** ```gem list```

* **Configuration:**
    - **In project directory, run:**
        - bundle install
        - yarn install
        
    - **In two seperate terminal, both in inside the project directory run:**
        - bundle exec rails s
        - bin/shakapacker-dev-server

* **Database creation**
    - **In project directory, run:**
        - sudo service postgresql start
        - cp config/database-sample.yml config/database.yml
        - Change database names in config/database.yml from project_development to rails_app_development_db and from project_test to rails_app_test_db 
        - rails db:create

* **Database initialization**
    - **In project directory, run:**
        - sudo service postgresql start
        - rails db:migrate
        - rails db:reset


* **How to run the test suite**
    - **In project directory, run:**
        - bundle exec rspec

* **Deployment instructions**
    - https://info.shefcompsci.org.uk/genesys/demos/team01.html

* **Admin account information**
    - username: admin1@example.com    password: Password@1234
    - username: admin2@example.com    password: Password@1234

* **Reporter account information**
    - username: reporter1@example.com     password: Password@1234
    - username: reporter2@example.com     password: Password@1234 
    - username: reporter3@example.com     password: Password@1234

* **Subscriber account information**
    - username: subscriber1@example.com     password: Password@1234
    - username: subscriber2@example.com     password: Password@1234 
    - username: subscriber3@example.com     password: Password@1234

* **AI demo fallback**

    The seeded "Demo AI Task" can show a clearly labelled pre-written fallback if Gemini(AI) is unavailable. This is for demo reliability only and is not a real AI-generated response.

    The fallback only applies when both conditions match:

    - Task name: "Demo AI Task"
    - Task description contains: "pre-seeded demo task"

* **Coding Standards**
    Our coding standards have been specified in the deliverable document. In summary we use:
    - “Ruby Style Guide,” Ruby Style Guide. [Online]. Available: https://rubystyle.guide/
    - “Rails Style Guide,” Rails Style Guide. [Online]. Available: https://rails.rubystyle.guide/
    - “RuboCop,” GitHub repository. [Online]. Available: https://github.com/rubocop/rubocop
    - “ESLint Documentation,” ESLint. [Online]. Available: https://eslint.org/docs/latest/

    **CI(CD)**
    It is important to clarify that there is no continuous deployment in our pipeline. Therefore for the sake of accuracy, we will just call it continuous integration, CI. There are three stages in the CI workflow – setup, test, and security. 

    - The pipeline first installs all required packages via bundler and yarn. 
    - Secondly, the workflow progresses to the testing stage, which runs RSpec. This is where we can see whether our tests succeeded or failed. 
    - Lastly, the security stage, which searches for vulnerabilities in dependencies from yarn and bundler. Furthermore, Brakeman is a vulnerability scanner designed for Ruby on Rails, analysing application code to “find security issues at any stage of development”.

    It is important to not merge your code to the main branch if at any point, a job fails in the CI workflow. If the pipeline succeeds, you can then create a merge request to deploy your code in the main branch. The point is to reduce the possibility of breaking the application completely for everyone on the main branch, which will introduce a lot of conflicts and reduce team cohesion.

* **Contribution Standard**
    The ideal software development workflow should be seamless, meaning minimal conflict resolution. In order to achieve this, learning how to sensibly create merge requests is crucial, we must follow best practices for Git, and practise code review. Merge requests allow us to implement a new feature outside of the main branch to avoid breaking anything important to the application and allows the team to discuss and track changes. A reviewer will discuss the changes you have made and approve the merge request if it is meaningful.

    - Do not merge if no one approves your merge request.
    - Make branch names meaningful
    - If we no longer want to use a branch, you should rename the branch to the month that you last looked at it 
    - Follow code review procedures

