import React, { useState } from "react";
import { IonButton, IonInput, IonItem, IonContent, IonPage, IonHeader, IonToolbar, IonTitle } from "@ionic/react";
import { RingCentral } from "../plugins/ringcentral";

const InputForm: React.FC = () => {
  const [userName, setUserName] = useState("Sarah Jones");
  const [inputValue, setInputValue] = useState("329178254");

  const handleSubmit = async () => {
    console.log("Input MeetingId", inputValue);
    await RingCentral.joinMeeting({
      meetingId: inputValue,
      userName: userName,
      apptEndTime: new Date(),
    });
  };

  return (
    <IonPage>
      <IonHeader>
        <IonToolbar>
          <IonTitle>RingCentral Ionic Sample</IonTitle>
        </IonToolbar>
      </IonHeader>
      <IonContent className='ion-padding'>
        <IonItem>
          <IonInput
            label='Enter Username'
            labelPlacement='stacked'
            clearInput
            value={userName}
            onIonChange={(e) => setUserName(e.detail.value!)}
            placeholder='Meeting ID'
          />
        </IonItem>
        <IonItem>
          <IonInput
            label='Enter MeetingID'
            labelPlacement='stacked'
            clearInput
            value={inputValue}
            onIonChange={(e) => setInputValue(e.detail.value!)}
            placeholder='Meeting ID'
          />
        </IonItem>
        <IonButton expand='block' onClick={handleSubmit}>
          Submit
        </IonButton>
      </IonContent>
    </IonPage>
  );
};

export default InputForm;
