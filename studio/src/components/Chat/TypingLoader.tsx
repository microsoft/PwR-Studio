import React from "react";
import styles from './loader.module.scss'

const BouncingDotsLoader = () => {
  return (
    <>
      <div className={styles.bouncingLoader}>
        <div></div>
        <div></div>
        <div></div>
      </div>
    </>
  );
};

export default BouncingDotsLoader;
