# Todo
This is a to-do list application for a single user. After installing dependencies, seeding db (via `mix ecto.setup`) starting server, go to `localhost:4000`. From here you can add new tasks with various attributes (labels, priority levels, etc.) as well as select a "Repeat" option and set an interval for the recurrence. The task will not be repeated in the list until the checkbox in the  "Done" column is checked for that particular task.

Tasks can be filtered on the main list by selecting various filtering buttons and sorted on most columns via the arrows under the column name. 

Click on a button to activate, click again to deactivate. For example, by default all tasks, 
from any date, are displayed. Clicking the date in the top row of buttons (which is today's date in UTC) will show tasks with Start Date of today. Clicking the button again will remove the date filter and will return the user to the default view. 

Date (first row, all dates vs. today only), completion status (second row), priority level (third row), and label (fourth row) filters can be combined, but for the moment only one selection from each filtering row can be selected at a time. 

The RESET button on the top right clears all filters.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`
  

