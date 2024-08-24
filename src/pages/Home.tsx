import { Capacitor } from "@capacitor/core";
import { useEffect, useState } from "react";
import InputForm from "./InputForm";
import { RingCentral } from "../plugins/ringcentral";

const Home: React.FC = () => {
  const [isLoading, setLoading] = useState(false);

  useEffect(() => {
    if (Capacitor.isNativePlatform()) {
      setLoading(true);
      // RingCentral Credential
      RingCentral.initRingCentral({
        clientId: import.meta.env.VITE_RC_CLIENT_ID ?? "",
        clientSecret: import.meta.env.VITE_RC_CLIENT_SECRET ?? "",
      }).finally(() => {
        setLoading(false);
      });
    }
  }, []);
  return isLoading ? <div>Loading</div> : <InputForm />;
};

export default Home;
