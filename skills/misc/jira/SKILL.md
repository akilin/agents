---
name: jira
description: 'Use when working with Jira tickets. Trigger phrases: "lets work on", "load information for ticket", "show tickets assigned to me", "show unassigned tickets"'
context: fork
user-invocable: false
---

# Work with Jira Tickets via Atlassian CLI
Use Atlassian CLI (`acli`) as the source of truth when the user wants to work with a Jira ticket.

# Workflows

## Pulling information about a ticket

When user asks to work on a ticket, look at a ticket, or pull information about a ticket - perform the next steps, using `acli` commands specified in [Commands](#commands) section:
- Pull basic information about the ticket
- Perform sanity checks specified in [Sanity checks](#sanity-checks) section.
- Pull comments attached to the ticket
- Pull linked work items. If there are any - pull basic information about them, and any attached comments.
- Pull attachments metadata. 
- If the ticket is in `To Do` status, ask the user if they want to transition it to `In Progress` before starting work. If the user agrees - transition it using the [Transition ticket to new status](#transition-ticket-to-new-status) command.
- Report back with all the information you have gathered (ticket fields, comments, linked items, attachments).

### Sanity checks
1) Check the ticket's assignee:
   - If unassigned - ask the user if they want to assign the ticket to themselves. If the user agrees - assign it using the [Assign ticket to the user](#assign-ticket-to-the-user) command.
   - If assigned to someone other than the current user - warn the user and ask them to confirm this is the intended ticket before proceeding. Do not reassign without explicit confirmation.
   - If already assigned to the current user - proceed.
2) Verify tickets current status allows to start working on it. If the ticket is in `To Do` or `In Progress` status - proceed. But if the ticket is in a `Blocked`/`In Review`/`Done`, or any other status - ask the user to confirm, that this is indeed the correct ticket, as it is not in a typical status for starting work. If the user confirms, proceed, if not - ask the user to specify the correct ticket.
3) If any `acli` command fails with an authentication error, instruct the user to run `acli jira auth login` themselves (it is interactive - do not run it on their behalf).

## Pulling a list of tickets

When user asks to show tickets assigned to them, or unassigned tickets, pull the list of tickets using `acli` commands specified in [Commands](#commands) section. For each ticket in the list, display next information:

- Key
- Type
- Priority
- Status
- Summary

# Commands

### Pull basic information about the ticket
```sh
  acli jira workitem view $key --fields "*all, -attachment, -comment"
```

### Pull comments attached to the ticket
```sh
  acli jira workitem comment list --key $key --paginate --json
```

### Pull linked work items
```sh
  acli jira workitem link list --key $key --json
```

### Pull attachments metadata
```sh
  acli jira workitem attachment list --key $key --json
```

### Open the ticket in the web interface
```sh
  acli jira workitem view $key --web
```

### Transition ticket to new status
```sh
acli jira workitem transition --key $key --status $status --yes
```
Common status values are  "To Do", "In Progress", "In Review", "Done", "Blocked" but they can be different in different Jira instances. 

### Assign ticket to the user
```sh
  acli jira workitem assign --key $key --assignee "@me" --yes
```

### Pull tickets assigned to the user in the current sprint

```sh
acli jira workitem search --jql "sprint in openSprints() AND assignee = currentUser() ORDER BY priority DESC" --fields "key,priority,issuetype,status,summary" --json
```

### Pull unassigned tickets in the current sprint

```sh
acli jira workitem search --jql "sprint in openSprints() AND assignee is EMPTY ORDER BY priority DESC" --fields "key,priority,issuetype,status,summary" --json
```

### Logging in
Interactive - instruct the user to run this themselves if authentication fails. Do not invoke it on their behalf.
```sh
  acli jira auth login
```
