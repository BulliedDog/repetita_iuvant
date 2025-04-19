# Repetita Iuvant
An ASSEMBLY code for error avoidance in a communication line, utilizing the redundancy technique to decode the message received to obtain the original one, minimizing transmission errors.

The redundancy check technique consists on dividing the string of bits of the received message into 3 digits chunks, each one gets inspected to determine the majority of 1s or 0s so that it determines the original bit that has been trasmitted 3 times consecutively.
This techinque is usefull because if an error occures while trasmitting (considering it already rare as an event), the corresponding 3 digits chunk still holds the majority of the correct bit from the original message and since getting 2 errors in the same chunk is considered extremely rare, it makes it a game changer on trasmitting data reliably 🤩

![image](https://github.com/user-attachments/assets/1b14a250-4275-48ce-a221-9378b832bb6e)

