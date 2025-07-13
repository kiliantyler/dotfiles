import img from '@assets/under_construction.svg';
import React from 'react';
import styles from './styles.module.css';

export interface StubComponentProps {
  title: string;
  iconStyle?: React.CSSProperties;
}

export const StubComponent: React.FC<StubComponentProps> = () => {
  return (
    <div>
      <h1>Coming Soon</h1>
      <p>We&apos;re working hard to create this page. Please check back later for updates.</p>
      <img src={img.src} alt="Under Construction" className={styles.stubImage} />
    </div>
  );
};

export default StubComponent;
