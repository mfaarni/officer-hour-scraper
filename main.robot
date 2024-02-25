*** Settings ***
Library   SeleniumLibrary
Library   Collections
Library   OperatingSystem
Library   DateTime

*** Test Cases ***
Scrape Office Hours
    Process Calendar
    Process Dates   

*** Keywords ***
Process Calendar
    Open Browser   url=https://hamalais-osakunta.fi/kalenteri   browser=chrome
    FOR    ${i}    IN RANGE    2 
        sleep      1s 
        ${elements}=   Get WebElements   class:paivystys
        FOR   ${element}   IN   @{elements}
            ${text}=    Get Text    ${element}
            ${contains_peruttu}=    Run Keyword And Return Status    Should Contain    ${text}    PERUTTU
            Run Keyword IF    ${contains_peruttu}    Continue For Loop
            Click Element   ${element}
            ${new_date}=    Get Text   class:sc_event_date  
            ${new_time}=    Get Text   class:sc_event_time
            ${formatted_date}=    Remove Prefix    ${new_date}    Päiväys:
            ${converted_date}=    Convert Date    ${formatted_date}    result_format=%Y-%m-%d    date_format=%d/%m/%Y
            ${formatted_time}=    Remove Prefix    ${new_time}    Aika:
            &{date}=      create dictionary    date=${converted_date}   time=${formatted_time}
            Append to list   ${officer_hours}   ${date}
            Go Back
        END
        Click Calendar Navigation
    END

Click Calendar Navigation
    ${next_element}=    Get WebElement    identifier:sc_next
    Click Element    ${next_element}


Process dates
    Create File  ${CURDIR}/dates.txt  
    FOR    ${date}    IN    @{officer_hours}
        ${str1}=    Append to file    ${CURDIR}/dates.txt    ${date}\n
    END
    Log to console     Dates saved to file.


Append Date To File
    [Arguments]    ${date}
    Append to file    ${CURDIR}/dates.txt    ${date}\n

Remove Prefix
    [Arguments]    ${string}    ${prefix}
    ${result}=    Evaluate    "${string}".replace("${prefix}", "").strip()  
    RETURN   ${result}

Get Next Week    
    ${today}    Get Current Date
    FOR    ${i}    IN RANGE    1    8
        ${next_day}=    Add Time To Date    ${today}    ${i} days
        ${formatted_date}=    Convert Date    ${next_day}     result_format=%Y-%m-%d    date_format=%Y-%m-%d %H:%M:%S.%f
        Append To List    ${next_week}    ${formatted_date}
    END
    RETURN    ${next_week}

*** Variables ***
@{officer_hours}=  
@{next_week}= 
