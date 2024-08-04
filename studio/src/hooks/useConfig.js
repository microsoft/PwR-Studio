import { useState, useEffect } from 'react';
import config from '../locales/config.json';

const useConfig = () => {
  const [configData, setConfigData] = useState(null);

  useEffect(() => {
    setConfigData(config);
  }, []);

  return configData;
};

export default useConfig;
