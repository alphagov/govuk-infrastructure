const numbers = libphonenumber.findPhoneNumbersInText(text, 'GB');

// Include the original string of the detected number
for (const key in Object.keys(numbers)) {
  number = numbers[key]
  number.text = text.substring(number.startsAt, number.endsAt)
}

return numbers
