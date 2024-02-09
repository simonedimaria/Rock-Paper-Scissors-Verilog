outputFile="simulate10b.script"

# Clear the existing output file
> "$outputFile"

# Loop through all binary numbers from 0 to 1023 (2^10 - 1)
for ((i=0; i<=1023; i++)); do
    binaryNumber=""
    
    # Convert the decimal number to binary
    decimalNumber="$i"
    for ((j=9; j>=0; j--)); do
        bit=$(( (decimalNumber >> j) & 1 ))
        binaryNumber="$binaryNumber $bit"
    done

    # Trim leading space
    binaryNumber="${binaryNumber:1}"

    # Append the modified line to the output file
    echo "simulate $binaryNumber" >> "$outputFile"

    # Add three new lines at the end of each line
    echo >> "$outputFile"
    echo >> "$outputFile"
    echo >> "$outputFile"
done

echo "Modified lines generated and saved to $outputFile"
